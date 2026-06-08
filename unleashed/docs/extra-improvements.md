# Extra Improvements

Smaller, targeted improvements that unlock Pascal patterns standard FPC modes reject. Some are gated on their own modeswitch (and enabled by default in `unleashed` mode); others are available only in `unleashed` mode without a dedicated switch.

> **Note for contributors:** if an improvement is available only in `unleashed` mode and has no dedicated modeswitch, say so in its description. That way readers can tell at a glance which features they can opt into from other modes via `{$modeswitch ...}` and which are `unleashed`-only.

## String-to-ordinal typecast in constant expressions

Cast a string literal of matching size directly to an ordinal type. The compiler packs the bytes in the target's native endianness into a compile-time constant, so the in-memory byte layout of the resulting value always matches the source byte order. The fold produces an `ordconstn`, so it works anywhere a constant is expected: `const`, `var` initializers, typed constants, and inline variables.

```pas
{$mode unleashed}

const
  MZ_SIG   = word('MZ');              // bytes: 'M' 'Z'
  RIFF_SIG = dword('RIFF');           // bytes: 'R' 'I' 'F' 'F'
  MAGIC_64 = qword('abcdefgh');       // bytes: 'a' 'b' ... 'h'

var
  g: dword = dword('abcd');           // global var initializer

procedure example;
begin
  var sig := dword('RIFF');           // inline var, inferred
  var m:  word := word('MZ');         // inline var, typed

  if pdword(@buf[0])^ = RIFF_SIG then
    ...
end;
```

### Supported target types

Any integer type whose size (1/2/4/8 bytes) matches the string length:

| Size    | Types                                     |
|---------|-------------------------------------------|
| 1 byte  | `Byte`, `ShortInt`                        |
| 2 bytes | `Word`, `SmallInt`                        |
| 4 bytes | `LongWord`, `DWord`, `Cardinal`, `LongInt`|
| 8 bytes | `QWord`, `Int64`                          |

### Size must match

A string literal of 3 characters cannot be cast to `DWord` - the compiler reports:

```
Error: Cannot cast string of length 3 to ordinal type "LongWord" (size 4 bytes)
```

### Packing is target-native, memory layout matches source

The packing uses the target's native endianness. The practical consequence: the in-memory byte layout of the folded constant is identical to the source character sequence on both little-endian and big-endian targets, so signature checks like `PDWORD(@buffer)^ = DWORD('RIFF')` work uniformly across platforms.

On a little-endian target (x86_64, ARM LE, RISC-V LE) `dword('abcd')` has numerical value `$64636261`, which stores as `61 62 63 64` in memory. On a big-endian target the numerical value is `$61626364`, which stores as `61 62 63 64` in memory. Same bytes either way.

### Char literals work too

The source can be any `cst_conststring` literal, including `#N`-escaped characters and mixed forms:

```pas
const
  cHex   = dword(#$DE#$AD#$BE#$EF);   // memory: $DE $AD $BE $EF
  cMixed = dword('AB'#$00#$01);       // memory: 'A' 'B' $00 $01
  cOne   = byte(#65);                 // memory: $41
```

## Type helpers and multi-helpers

Two existing FPC modeswitches re-surfaced for unleashed. Nothing is invented here - just less ceremony to use features Pascal already has. Both are off by default in `{$mode unleashed}` and must be opted into explicitly via `{$modeswitch ...}`.

`typehelpers` enables `type helper for T` on any named type, not just classes and records:

```pas
{$mode unleashed}
{$modeswitch typehelpers}
type
  TIntHelper = type helper for integer
    function Doubled: integer;
  end;

  TIntArr = type array of integer;
  TIntArrHelper = type helper for TIntArr
    function ToString: string;
  end;

function TIntHelper.Doubled: integer;
begin
  Result := Self * 2;
end;

function TIntArrHelper.ToString: string;
var i: integer;
begin
  Result := '[';
  for i := 0 to High(Self) do begin
    if i > 0 then Result := Result + ', ';
    Result := Result + IntToStr(Self[i]);
  end;
  Result := Result + ']';
end;

var
  n: integer;
  a: TIntArr;
begin
  n := 21;
  writeln(n.Doubled);          // 42

  a := [1, 2, 3];
  writeln(a.ToString);         // [1, 2, 3]
end.
```

`multihelpers` lets several helpers for the same type be visible at the same time (by default each scope sees only the last one). Useful when two units each ship a helper for `integer` and you want methods from both.

## Implicit generics syntax in any mode

Stock FPC accepts Delphi-style generic syntax (no `generic` / `specialize` keywords, plain `<T>` in declarations and specializations) only in `{$mode delphi}`. The recognition rules for these keywords and for `<T>` were hard-coded against `m_delphi`, so even if you only wanted that one piece of Delphi syntax you had to switch the entire mode.

Unleashed splits that recognition out into its own modeswitch, `implicitgenerics`. It is on by default in `delphi` (no behavior change there) and `unleashed`, and can be turned on in any other mode - `objfpc`, `tp`, etc. - with `{$modeswitch implicitgenerics}`:

```pas
{$mode objfpc}{$H+}
{$modeswitch implicitgenerics}

type
  TList<T> = class
    procedure Add(const Item: T);
  end;

var
  L: TList<integer>;
```

Without the switch in non-Delphi modes you still write the explicit form (`generic TList<T>` / `specialize TList<integer>`); the switch only adds the implicit form on top, it does not remove anything.

## Nested generic methods

Stock FPC rejects any `generic` declared inside another `generic` with `Fatal: Declaration of generic inside another generic is not allowed`, so a generic class cannot carry a generic method of its own:

```pas
generic TBox<T> = class
  generic procedure Map<U>(item: U);   // stock FPC: rejected
end;
```

The block was an implementation limit, not a language one. FPC records a generic's body as a replayable token stream into a single buffer; nesting one generic inside another needs a second recording in flight, which the single buffer could not hold (it raised an internal error), so the parser forbade the construct outright. Delphi has supported generic methods on generic classes for years.

In `unleashed` mode the restriction is lifted. A generic class or record can declare a method with its own type parameter list, independent of the enclosing type's:

```pas
{$mode unleashed}

type
  TBox<T> = class
    FValue: T;
    function Pair<U>(const a: T; const b: U): string;
  end;

function TBox<T>.Pair<U>(const a: T; const b: U): string;
begin
  FValue := a;
  Result := Format('T=%d U=%d', [SizeOf(T), SizeOf(U)]);
end;

var
  b: TBox<Integer>;                  // class specialized once, T = Integer
begin
  b := TBox<Integer>.Create;
  writeln(b.Pair<Byte>(10, 5));      // method specialized here: U = Byte
  writeln(b.Pair<Double>(20, 3.14)); // same method, different U: U = Double
end.
```

The class and the method specialize independently: `TBox<Integer>` fixes `T`, and each call site picks its own `U`. The nested template survives `.ppu` serialization, so a generic method declared in one unit specializes correctly when called from another. Nested generic types inside a generic, type-parameter constraints on the nested method (`Foo<U: class>`), and managed `U` types all work.

Available only in `unleashed` mode, no dedicated modeswitch.

## Compound assignment on properties

Stock FPC rejects `prop += x` (and all other compound forms `-=`, `*=`, `/=`, `and=`, `or=`, `xor=`, `mod=`, `div=`, `shl=`, `shr=`) on a class or record property with `Error: Variable identifier expected`. The reasoning in the parser comment is that the read accessor and the write accessor can target different storage, so the rewrite into `prop := prop + x` was disallowed even though it is exactly what the user has to type by hand.

In `unleashed` mode the compound forms work directly:

```pas
{$mode unleashed}
{$coperators on}

type
  TFoo = class
  private
    FName: string;
    FCount: integer;
    function GetName: string;
    procedure SetName(const v: string);
  public
    property Name: string read GetName write SetName;
    property Count: integer read FCount write FCount;
  end;

var
  f: TFoo;
begin
  f.Name := 'foo';
  f.Name += 'bar';     // -> f.Name := f.Name + 'bar'
  f.Count += 5;        // direct field access on both sides
  f.Count *= 2;
end;
```

The expansion is the same node tree the user would build manually: one getter call on the read side, the binary operator, one setter call on the write side. Side effects in the accessors fire exactly as in the manual rewrite, no more and no fewer.

Available only in `unleashed` mode, no dedicated modeswitch. The C-style operators (`+=`, `-=`, `*=`, `/=`) still require `{$coperators on}` or `-Sc` as in any FPC mode; the word-based operators (`and=`, `or=`, ..., `shl=`, `shr=`) work without it.

### Limitations

Each rejection comes with its own error message instead of the generic `Variable identifier expected`:

- Indexed properties (`property X index N: ...`) and parametrized properties (`property Items[i: integer]: ...`) report `Compound assignment and inc/dec are not supported on indexed or parametrized property "X"`. Use the explicit rewrite.
- A property without a write accessor reports `Property "X" has no write accessor`.

## `inc` / `dec` on properties

Same restriction in stock FPC: `inc(prop)` and `dec(prop, n)` need a `var` argument and a property cannot be passed by `var` (the getter/setter pair would be skipped). Stock reports `Error: Can't take the address of constant expressions`.

In `unleashed` mode `inc` / `dec` rewrite to a setter call carrying `getter +/- delta`:

```pas
{$mode unleashed}

type
  TCounter = class
  private
    FN: integer;
    function GetN: integer;
    procedure SetN(v: integer);
  public
    property N: integer read GetN write SetN;
  end;

var c: TCounter;
begin
  inc(c.N);        // -> c.N := c.N + 1
  inc(c.N, 5);     // -> c.N := c.N + 5
  dec(c.N);        // -> c.N := c.N - 1
  dec(c.N, 10);    // -> c.N := c.N - 10
end;
```

The same accessors fire as for the explicit rewrite or the compound form `c.N += 1`. Pick whichever reads better for the surrounding code.

### Limitations

Same dedicated messages as for compound assignment, plus a type check:

- The getter must be a method (`read GetN`). A field-backed read accessor (`read FN`) is not rewritten and continues to give the stock error - use the field directly or the compound form `prop += n`.
- Indexed and parametrized properties report `Compound assignment and inc/dec are not supported on indexed or parametrized property "X"`.
- Read-only properties report `Property "X" has no write accessor`.
- Property type must be ordinal, enum, pointer, or currency. Anything else reports `inc/dec property "X" must be ordinal, enum, pointer, or currency, not "T"`. For string properties use compound assignment (`prop += '...'`) instead.

## `array[N]` size shorthand

Standard Pascal spells a fixed array of 10 integers `array[0..9] of integer` - one literal up, one literal down, a range operator, and the reader has to subtract to figure out the element count. In `unleashed` mode a bare positive integer constant inside the brackets is the element count itself:

```pas
{$mode unleashed}

var
  a: array[10] of integer;       // 0..9, ten elements
  m: array[3, 4] of integer;     // 0..2 by 0..3, twelve elements
  b: array[BUF] of byte;         // BUF = 8 - same as array[0..7] of byte
```

Multi-dim works through the same comma loop the long form uses, so shortcut indices freely mix with explicit ranges and type-indexed dimensions:

```pas
var
  k: array[5, 'a'..'c'] of integer;  // 0..4 by 'a'..'c'
  e: array[TEnum, 4] of integer;     // TEnum by 0..3
```

Memory layout is identical to the explicit form: a single contiguous block, row-major. `Move`, `FillChar`, `SizeOf`, `BlockRead/Write` see one flat span exactly as they do for `array[1..N, 1..M]`. Dynamic arrays (`array of array of T`) are a separate construct and remain heap-scattered.

`N` must be a positive integer constant expression - `array[0]` and `array[-5]` are rejected with `Upper bound of range is less than lower bound`, the same diagnostic stock FPC emits for `array[5..0]`.

The shortcut sits next to the existing forms, not in place of them. Ranges (`array[1..10]`, `array[-5..5]`), type-indexed (`array[TEnum]`, `array[Boolean]`, `array['a'..'z']`), dynamic (`array of T`), open (`array of const` parameters), and FAM (`array[] of T` under `flexiblearrays`) are unchanged.

`string[N]` is **not** affected: it keeps its classic meaning of "shortstring with max length N" because the `string[...]` syntax goes through a different parser path entirely. The new shortcut only fires inside `array[...]`.

Available only in `unleashed` mode, no dedicated modeswitch.

## Modeswitch

| Modeswitch          | Default in `unleashed` | Purpose                                                 |
|---------------------|-----------------------|----------------------------------------------------------|
| `stringordcast`     | on                    | String-literal typecast to ordinal                       |
| `typehelpers`       | on                    | `type helper for T` on any named type                    |
| `multihelpers`      | on                    | Multiple helpers for the same type visible in one scope  |
| `implicitgenerics`  | on                    | Delphi-style implicit `generic` / `specialize` / `<T>`   |

To enable in another mode:

```pas
{$mode objfpc}{$H+}
{$modeswitch stringordcast}
{$modeswitch typehelpers}
{$modeswitch multihelpers}
{$modeswitch implicitgenerics}
```

To opt out of the default-on switches in `unleashed` mode:

```pas
{$mode unleashed}
{$modeswitch stringordcast-}
```
