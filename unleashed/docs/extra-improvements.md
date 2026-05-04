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

Unleashed splits that recognition out into its own modeswitch, `implicitgenerics`. It is on by default in `delphi` (no behavior change there) and can be turned on in any other mode - `objfpc`, `tp`, `unleashed`, etc. - with `{$modeswitch implicitgenerics}`:

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

- Indexed properties (`property X index N: ...`) and parametrized properties (`property Items[i: integer]: ...`) are not supported. Use the explicit rewrite for those.
- Property must have both `read` and `write` accessors.

## Modeswitch

| Modeswitch          | Default in `unleashed` | Purpose                                                 |
|---------------------|-----------------------|----------------------------------------------------------|
| `stringordcast`     | on                    | String-literal typecast to ordinal                       |
| `typehelpers`       | off                   | `type helper for T` on any named type                    |
| `multihelpers`      | off                   | Multiple helpers for the same type visible in one scope  |
| `implicitgenerics`  | off                   | Delphi-style implicit `generic` / `specialize` / `<T>`   |

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
