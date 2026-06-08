# Lightweight Generics - shared bodies across same-shape specializations

Stock Pascal generics are monomorphized: every `TList<TFoo>` and `TList<TBar>` gets its own copy of every method body, even when the two copies are byte-identical on the target ABI. For pointer-typed parameters that is pure duplication - every class reference, interface, and raw pointer is moved around the same way (a single 8-byte load/store on x64). Lightweight generics removes that duplication by emitting one body per ABI shape and pointing every same-shape specialization at it.

## Enabling

Opt-in modeswitch, not on by default in `{$mode unleashed}`:

```pas
{$mode unleashed}
{$modeswitch lightgenerics}
```

Without the modeswitch, code compiles exactly as before. With it, same-shape specializations share method bodies. Type identity is untouched either way: `is`/`as`, RTTI, distinct VMTs, and distinct types all behave normally - only the machine code behind the methods is shared.

## How it works

The compiler classifies each type parameter into an ABI shape bucket based on how the type is passed and copied at the machine level:

| Shape           | Members                                                                     |
|-----------------|-----------------------------------------------------------------------------|
| `Shape_Ref`     | class refs, interfaces, raw pointers, classref, procvar, dynamic arrays     |
| `Shape_POD_1`   | 1-byte unmanaged scalars (`Byte`, `Boolean`, 1-byte enums)                  |
| `Shape_POD_2`   | 2-byte unmanaged scalars (`Word`, `SmallInt`)                               |
| `Shape_POD_4`   | 4-byte unmanaged scalars (`Integer`, `LongWord`, 4-byte enums)              |
| `Shape_POD_8`   | 8-byte unmanaged scalars (`Int64`, `QWord`)                                 |
| `Shape_Managed` | ARC types (`AnsiString`, `UnicodeString`, dynamic arrays, managed records)  |
| `Shape_Complex` | fixed-size records that are not POD-sized                                   |

Two specializations share a method body when every type parameter lands in the same bucket and the monomorphized body for that bucket is byte-identical. `Shape_Ref` always qualifies (every reference is the same pointer move). `Shape_POD_N` qualifies within a single width (`TCell<Integer>` and `TCell<LongWord>` both reduce to a 4-byte move; `TCell<Int64>` is a separate 8-byte body). Floats are deliberately excluded even though their width matches the integer buckets, because they move through fpu/xmm registers and produce different code.

Multi-parameter generics use a composite key built from each parameter's shape in declaration order, so `TPair<TFoo, Integer>` (ref + pod4) and `TPair<TFoo, Int64>` (ref + pod8) get different keys and never collide, while `TPair<TFoo, TBar>` and `TPair<TFoo, TBaz>` (both ref + ref) share.

The shared body is emitted once under a canonical symbol name that encodes the generic type, the method, and the shape key, for example:

```
<module>_$LWG_ref$_TBox_SetValue$2_ref
```

Every same-shape specialization routes its VMT slot and its call sites to that symbol instead of emitting its own body.

## Verifying it works

Two specializations of a same-shape generic resolve to the same code address:

```pas
program lwg_proof;
{$mode unleashed}
{$modeswitch lightgenerics}

type
  TBox<T> = class(TObject)
    FValue: T;
    procedure SetValue(const AValue: T); virtual;
  end;

procedure TBox<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
end;

type
  TFoo = class end;
  TBar = class end;
  TBoxFoo = TBox<TFoo>;
  TBoxBar = TBox<TBar>;

var
  bf: TBoxFoo;
  bb: TBoxBar;
  mf, mb: TMethod;
begin
  bf := TBoxFoo.Create;
  bb := TBoxBar.Create;
  mf := TMethod(@bf.SetValue);
  mb := TMethod(@bb.SetValue);
  if mf.Code = mb.Code then WriteLn('shared') else WriteLn('separate');
end.
```

Prints `separate` without the modeswitch, `shared` with it. On a larger program you can also compare the `.exe`: a generic with N methods specialized over M same-shape types drops from roughly `N*M` bodies to `N`.

## What shares

| Routine                                   | shares?                                  |
|-------------------------------------------|------------------------------------------|
| Regular instance method                   | yes                                      |
| Class method / static method              | yes                                      |
| Property getter / setter                  | yes                                      |
| Instance constructor / destructor         | yes                                      |
| Generic record methods                    | yes                                      |
| Standalone generic function               | yes                                      |
| Same-shape POD specializations            | yes (within one width)                   |
| Mixed-shape specializations               | yes (matched by composite key)           |
| Cross-module specializations              | yes (see below)                          |

Constructors and destructors share because the per-class VMT allocation and finalization happen in the runtime's `NewInstance`/`FreeInstance`, outside the body; the body itself is byte-identical across same-shape specializations.

## What does not share

These stay on the stock per-specialization path. For each, the modeswitch is a sound no-op - the affected routine compiles exactly as it would without it.

- **Floating-point specializations** (`TBox<Single>`, `TBox<Double>`) - distinct register ABI, excluded from the POD buckets.
- **Class constructors / class destructors and operator overloads** - per-class state and operator dispatch are not byte-identical across specializations.
- **Managed bodies that assign the type parameter** - a body doing `FValue := A` where `T` is managed lowers to a type-specific ARC helper (`fpc_ansistr_assign` vs `fpc_dynarray_assign` etc.), so it falls back to a per-spec body. A managed specialization whose body never assigns `T` - for example a getter that returns an integer count - still shares.
- **Bodies that depend on the concrete identity of `T`** - `TypeInfo(T)`, `obj as T`, `obj is T`, or an explicit class-ref load bake in the first specialization's type. These are detected after parsing and that one method silently reverts to monomorphization; the rest of the type still shares.

## Cross-module sharing

The canonical name is built from the generic template's home module, not the consuming module, so every unit that specializes the same template under the same shape agrees on one symbol. Each module records the canonicals it emitted into its PPU; a downstream unit that imports the PPU sees them and skips re-emitting, letting the linker resolve cross-module calls to the single body in whichever object file emitted it first.

Forward-compat cost is minimal: a PPU written before this feature simply carries no canonical list and its consumers fall back to per-module dedup. A compiler without the feature rejects a PPU that carries the list - but such a compiler also does not know the modeswitch, so this only matters when mixing toolchains that already disagree.

## What this is not

- **Not a runtime cost** for the shared-by-identity cases (Ref and POD): no witness table, no hidden parameter, no extra indirection. It is purely a link-time identity change - the same machine code, reached through a shared symbol.
- **Not an ABI change**: callers and callees use the same registers and stack layout with or without the modeswitch. Only the symbol name they resolve to differs.
- **Not a type-identity change**: `TBoxFoo` and `TBoxBar` remain distinct types in source and at runtime. The only visible difference is that a stack frame for a shared method shows the canonical symbol name rather than a per-specialization one.

## Avoiding surprises

A shared body sees `T` only as a same-shape handle. As long as the body manipulates `T` through assignment, parameter passing, return values, `nil` comparison, and calls back through `Self`, sharing is safe and transparent. Bodies that reach for `T`'s concrete identity (`TypeInfo(T)`, casting to `T`, calling a class method on `T`) are either detected and reverted automatically or, if you hit a case that is not, can be kept per-type by not enabling the modeswitch on that unit. Classic container code (`TList<T>`, `TDictionary<TKey, TValue>`, `TBox<T>`) does not run into this.
