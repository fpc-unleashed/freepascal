# Multi-Variable Initialization

Initialize several variables of the same type with a single value in one declaration: `a, b, c: integer = 42;`. Works in `var` sections (global and local), typed `const` sections, and inline `var` statements. Each name gets its own independent copy of the value.

Modeswitch: `multivarinit`, enabled by default in `{$mode unleashed}`. Opt in from another mode with:

```pascal
{$mode objfpc}
{$modeswitch multivarinit}
```

## `var` sections

```pascal
var
  a, b, c: integer = 42;
  x, y: double = 3.14;
  ok, done: boolean = false;
```

Global variables each get their own copy of the value in the data segment. Local variables share a single internal default-value symbol; the compiler assigns it to each variable at routine entry, exactly as it does for single-variable defaults:

```pascal
procedure foo;
var
  la, lb, lc: integer = 10;
begin
  // la = 10, lb = 10, lc = 10
end;
```

## Typed constants

```pascal
const
  MIN_X, MIN_Y, MIN_Z: integer = 0;
  MAX_X, MAX_Y, MAX_Z: integer = 100;
```

Each constant gets its own storage in the constant data section (read-only under `{$J-}`). Aggregate typed constants work too - the initializer is re-parsed per name via token replay:

```pascal
type
  TPoint = record x, y: integer; end;

const
  ORIGIN, FALLBACK: TPoint = (x: 0; y: 0);
```

## Inline `var`

With `inlinevars` active (default in unleashed mode) the multi-name form works at the point of use, with an explicit type or with inference:

```pascal
var p, q: integer := 99;    // explicit type
var i, j := 10;             // both LongInt (inferred)
var s1, s2 := 'hello';      // both AnsiString
```

Inference follows the regular inline-var rules: sub-32-bit integers promote to `LongInt`, character literals to the mode's default string type.

### Initializer runs once

For inline declarations the expression is evaluated once into a hidden temporary and then assigned to each name. A function call in the initializer executes exactly one time:

```pascal
var a, b, c := computeValue; // computeValue called once, result copied 3x
```

## Semantics

### Value copy, not aliasing

Every variable receives an independent copy. After initialization they are unrelated:

```pascal
var a, b: integer = 1;
a := 42;
// b is still 1
```

### Evaluation per context

| Context | Evaluation |
|---|---|
| `var` section (global / local) | parsed once at compile time as a typed constant |
| `const` section | parsed once at compile time per name (token replay) |
| inline `var` with `:=` | evaluated once at runtime, assigned to each name |

`var` / `const` sections keep the classic requirement of a compile-time constant expression; runtime expressions are allowed only in the inline form.

### Compatibility

With a single name the behavior is identical to stock FPC - the modeswitch adds no overhead and changes no existing semantics. Code that never lists more than one name per initializer compiles bit-for-bit the same.

## Limitations

- `threadvar` cannot have initializers (same as stock FPC).
- The `absolute` and `external` directives stay single-variable only.

## IDE support

Lazarus CodeTools recognize the multi-name syntax in `const` sections; code completion resolves the type for every name in the list, so member completion works on any of them.

## Demo

```pascal
program multi_var_init_demo;

{$mode unleashed}

var
  calls: integer = 0;

function nextSeed: integer;
begin
  inc(calls);
  result := calls*100;
end;

const
  MIN_X, MIN_Y: integer = 0;
  MAX_X, MAX_Y: integer = 100;

var
  hp, mp, xp: integer = 50;

begin
  writeln($'bounds: x {MIN_X}..{MAX_X}, y {MIN_Y}..{MAX_Y}');
  writeln($'hp={hp} mp={mp} xp={xp}');

  hp := 75;
  writeln($'after hp := 75: hp={hp} mp={mp} (independent copies)');

  // inline: initializer evaluated once, assigned to each name
  var s1, s2, s3 := nextSeed;
  writeln($'s1={s1} s2={s2} s3={s3}, nextSeed called {calls} time(s)');

  var w, h: integer := 640;
  writeln($'w={w} h={h}');
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
bounds: x 0..100, y 0..100
hp=50 mp=50 xp=50
after hp := 75: hp=75 mp=50 (independent copies)
s1=100 s2=100 s3=100, nextSeed called 1 time(s)
w=640 h=640
```
