# Compound Assignment

Modify-and-assign in one statement, for every binary operator Pascal has - not just the four C-style symbols. Three layers, each with its own availability:

| Layer | Operators | Availability |
|---|---|---|
| Word-based operators | `div=`, `mod=`, `and=`, `or=`, `xor=`, `shl=`, `shr=` | every mode, no switch, independent of `{$coperators}` |
| C-style operators | `+=`, `-=`, `*=`, `/=` | on automatically in `{$mode unleashed}`; other modes need `{$coperators on}` / `-Sc` |
| Properties as targets | all of the above, plus `inc()` / `dec()` | `{$mode unleashed}` only, no dedicated modeswitch |

## Word-based operators

`x OP= y` is exactly `x := x OP y`. The target is evaluated once.

| Operator | Equivalent to | Operand types |
|----------|---------------|------------------|
| `div=` | `x := x div y` | integer |
| `mod=` | `x := x mod y` | integer |
| `and=` | `x := x and y` | integer, boolean |
| `or=` | `x := x or y` | integer, boolean |
| `xor=` | `x := x xor y` | integer, boolean |
| `shl=` | `x := x shl y` | integer |
| `shr=` | `x := x shr y` | integer |

```pascal
var i := 100;
i div= 3;       // 33
i mod= 10;      // 3

var flags: longword := $FF;
flags and= $0F; // $0F
flags or= $30;  // $3F
flags xor= $05; // $3A
flags shl= 4;   // $3A0
flags shr= 2;   // $E8

var ok := true;
ok and= (i = 3); // boolean forms accumulate conditions
ok or= (i < 0);
```

They work in `fpc`, `objfpc`, `delphi`, and `unleashed` alike - a unit that never touches `{$mode unleashed}` can still use them.

### One token pair, no space

The operator is the keyword followed immediately by `=`. A space between them breaks the parse - `i div = 3;` reads as `i div (= 3)` and reports `Error: Illegal expression`:

```pascal
i div= 3;   // OK
i div = 3;  // Error: Illegal expression
```

## C-style operators

`+=`, `-=`, `*=`, `/=` are stock FPC syntax behind `{$coperators on}` (or `-Sc`). Unleashed mode flips that switch on automatically, so they work with no directive:

```pascal
{$mode unleashed}

var x := 10;
x += 5;   // 15
x -= 3;   // 12
x *= 2;   // 24
x /= 4;   // only on floats - x here is integer, so this line would not compile
```

`{$coperators off}` switches them back off locally if a unit needs that.

## Properties as targets

Stock FPC rejects a property on the left of any compound form with `Variable identifier expected`, and rejects `inc(prop)` / `dec(prop)` with `Can't take the address of constant expressions` - a property is not a variable, and its getter / setter pair cannot be passed by reference. Unleashed mode rewrites both shapes into the accessor calls you would type by hand.

### Compound assignment on properties

`prop OP= x` expands to `prop := prop OP x`: one getter call, the binary operator, one setter call. No accessor fires twice, no accessor is skipped.

```pascal
{$mode unleashed}

type
  TFoo = class
  private
    fname: string;
    fcount: integer;
    function getName: string;
    procedure setName(const v: string);
  public
    property name: string read getName write setName;
    property count: integer read fcount write fcount;
  end;

var f: TFoo;
begin
  f.name += 'bar';   // -> f.name := f.name + 'bar' (getName once, setName once)
  f.count += 5;      // field-backed: plain field read + write
  f.count *= 2;
end;
```

Every compound form participates: `+=`, `-=`, `*=`, `/=`, `div=`, `mod=`, `and=`, `or=`, `xor=`, `shl=`, `shr=`. The property may be method-backed, field-backed, or mixed; string properties grow with `+=` like string variables do.

### `inc()` / `dec()` on properties

`inc(prop)`, `inc(prop, n)`, `dec(prop)`, `dec(prop, n)` rewrite to a setter call carrying `getter + delta` / `getter - delta`:

```pascal
type
  TCounter = class
  private
    fn: integer;
    function getN: integer;
    procedure setN(v: integer);
  public
    property n: integer read getN write setN;
  end;

var c: TCounter;
begin
  inc(c.n);      // -> c.n := c.n + 1
  inc(c.n, 5);   // -> c.n := c.n + 5
  dec(c.n, 2);   // -> c.n := c.n - 2
end;
```

The same accessors fire as for the explicit rewrite or the compound form `c.n += 1` - pick whichever reads better in context.

Restrictions specific to `inc()` / `dec()`:

- The read accessor must be a method (`read getN`). A field-backed read accessor (`read fn`) keeps the stock error `Can't take the address of constant expressions` - use the field directly or the compound form `prop += n`.
- The property type must be ordinal, enum, pointer, or currency. Anything else reports `inc/dec property "X" must be ordinal, enum, pointer, or currency, not "T"`. For string properties use `prop += '...'`.

### Rejections

Each unsupported shape has a dedicated message instead of the generic stock error:

| Situation | Message |
|---|---|
| Indexed property (`property X index N: ...`) or parametrized property (`property Items[i: integer]: ...`) | `Compound assignment and inc/dec are not supported on indexed or parametrized property "X"` - write the explicit `X := X + n` rewrite |
| Property without a write accessor | `Property "X" has no write accessor` |
| Property without a read accessor | `No member is provided to access property` |
| `inc()` / `dec()` with field-backed read accessor | stock `Can't take the address of constant expressions` |
| `inc()` / `dec()` on a non-ordinal property | `inc/dec property "X" must be ordinal, enum, pointer, or currency, not "T"` |

## Demo

```pascal
program compound_demo;

{$mode unleashed}

// 8-bit Galois LFSR, taps $B8: shr= and xor= drive the state
function nextLFSR(seed: byte): byte;
begin
  result := seed;
  var lsb := result and 1;
  result shr= 1;
  if lsb = 1 then result xor= $B8;
end;

begin
  // digit sum: mod= peels the last digit, div= drops it
  var n := 941075;
  var sum := 0;
  while n > 0 do begin
    sum += n mod 10;
    n div= 10;
  end;
  writeln($'digit sum of 941075 = {sum}');

  // bit surgery on a flags word
  var flags: longword := $FF;
  flags and= $0F; // keep low nibble          -> $0F
  flags or= $30;  // set bits 4-5             -> $3F
  flags xor= $05; // toggle bits 0 and 2      -> $3A
  flags shl= 4;   // shift into high position -> $3A0
  flags shr= 2;   // and back down            -> $E8
  writeln($'flags = ${HexStr(flags, 2)}');

  // boolean accumulation
  var allPositive := true;
  for var v in [3, 7, 1, 9] do allPositive and= (v > 0);
  writeln($'all positive: {allPositive}');

  // six LFSR steps from seed 1
  var s: byte := 1;
  write('lfsr: ');
  for var i := 1 to 6 do begin
    s := nextLFSR(s);
    write(s, ' ');
  end;
  writeln;
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
digit sum of 941075 = 26
flags = $E8
all positive: TRUE
lfsr: 184 92 46 23 179 225
```
