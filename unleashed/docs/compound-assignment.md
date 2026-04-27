# Compound Assignment for Pascal Operators

Use `div=`, `mod=`, `and=`, `or=`, `xor=`, `shl=`, and `shr=` as shorthand for modify-and-assign.

Always available in all modes (`objfpc`, `delphi`, `unleashed`, etc.) without any switch. These are word-based operators and do not depend on `{$coperators on}`.

## Operators

| Operator | Equivalent to     | Operand types        |
|----------|--------------------|----------------------|
| `div=`   | `x := x div y`    | integer types        |
| `mod=`   | `x := x mod y`    | integer types        |
| `and=`   | `x := x and y`    | integer, boolean     |
| `or=`    | `x := x or y`     | integer, boolean     |
| `xor=`   | `x := x xor y`    | integer, boolean     |
| `shl=`   | `x := x shl y`    | integer types        |
| `shr=`   | `x := x shr y`    | integer types        |

## Examples

### Integer arithmetic

```pas
var i: integer;
i := 100;
i div= 3;  // i = 33
i mod= 10; // i = 3
```

### Bitwise operations

```pas
var flags: longword;
flags := $FF;
flags and= $0F; // flags = $0F
flags or=  $30; // flags = $3F
flags xor= $05; // flags = $3A
flags shl= 4;   // flags = $3A0
flags shr= 2;   // flags = $E8
```

### Boolean operations

```pas
var ok: boolean;
ok := true;
ok and= (x > 0); // ok = ok and (x > 0)
ok or=  (y > 0); // ok = ok or (y > 0)
```

## C-style operators

The symbol-based operators (`+=`, `-=`, `*=`, `/=`) require `{$coperators on}` in standard modes. In unleashed mode they are available without the switch:

```pas
var x: integer := 10;
x += 5;  // 15
x -= 3;  // 12
x *= 2;  // 24
```

## Syntax

The operator is two tokens: the keyword (`div`, `mod`, `and`, `or`, `xor`, `shl`, `shr`) followed immediately by `=`. No space between the keyword and `=`:

```pas
i div= 3;  // OK
i div = 3; // parsed as: i div (= 3) - syntax error
```
