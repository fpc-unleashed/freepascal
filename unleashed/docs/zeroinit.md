# `zeroinit` procedure modifier

`procedure foo; zeroinit;` zero-initialises every local variable at function entry. Each local gets an implicit `Default(typeof(local))` assignment inserted at the start of the body, in declaration order, before any user statement runs.

Available in `{$mode unleashed}`. There is no separate modeswitch.

## What it does

```pas
procedure DoWork; zeroinit;
var
  i, j: Integer;
  s: String;
  r: TPoint;
begin
  // i = 0, j = 0, s = '', r = zero-filled before any statement here
end;
```

Adding a new local makes it zeroed too, no need to update an explicit list.

The injection happens after tuple destructure assignments have already been resolved, so a destructured parameter that writes into a local still wins over the zero.

## Why

By default, FPC initialises managed locals (`string`, dynamic arrays, interfaces, `Variant`) but leaves simple types (`Integer`, plain records, static arrays) with whatever the stack carries from earlier calls. Most procedures dodge the issue by assigning before reading, but defensive code, code-generation targets, FFI shims, and one-off prototypes lose time hunting "why is this zero sometimes and 0x7FFFA32C other times" bugs.

`zeroinit` removes the question: the local frame is deterministic on entry, the same way it would be if you wrote `:= 0` next to every declaration.

## Where it can be applied

Stand-alone procedures and functions, methods on classes and records. Constructors and destructors are allowed.

```pas
type
  TCalc = class
    function Sum: Integer; zeroinit;
  end;

function TCalc.Sum: Integer;
var
  a, b, c: Integer;
begin
  Inc(a, 10); Inc(b, 20); Inc(c, 30);
  Result := a + b + c;  // = 60, a/b/c started at 0
end;
```

## Where it cannot be applied

The directive is mutually exclusive with `external`, `interrupt`, and `assembler`: those have no Pascal body to inject into.

```pas
procedure DoNothing; external 'foo.dll'; zeroinit;  // rejected
```

## Function result

The function `Result` variable is treated as a regular local: it is also zeroed. For a function with a managed return type FPC already zeroes the result anyway, so this only changes behaviour for unmanaged types - which is usually what you want, since the result you read before assigning was previously indeterminate.

## Anonymous compound types: silently skipped

A local declared with an inline anonymous compound type (no named alias) is **not** zeroed:

```pas
procedure Foo; zeroinit;
var
  arr: array[0..3] of Integer;  // anonymous - skipped
  i: Integer;                   // covered
begin
  // i = 0, arr is still whatever the stack carried
end;
```

The reason is internal: `Default(T)` looks up a hidden zero-value typed constant via `T`'s symbol name, and an inline anonymous type has no symbol to mangle. The implementation skips those locals to avoid crashing the compiler. Workaround: name the type.

```pas
type
  TArr4 = array[0..3] of Integer;

procedure Foo; zeroinit;
var
  arr: TArr4;  // named alias - covered
begin
  // arr[0..3] all zero
end;
```

## Codegen

`zeroinit` injects ordinary assignment nodes; it does not change the calling convention, stack frame, or register usage. After the injection the routine looks to subsequent compilation phases exactly like the user had written the zero-assignments by hand. There is no runtime helper, no extra symbol, and no PPU change beyond a single implprocoption bit on the routine itself.
