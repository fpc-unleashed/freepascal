# Multi-Variable Initialization

Initialize multiple variables of the same type with a single value in one declaration. Works in `var`, `const` (typed constants), and inline `var` statements.

Feature gated by modeswitch `MULTIVARINIT`, enabled by default in `{$mode unleashed}`.

```pas
{$mode objfpc}
{$modeswitch multivarinit}
```

## Global variables

```pas
var
  a, b, c: integer = 42;
  x, y:    double  = 3.14;
  ok, done: boolean = false;
```

Each variable gets its own copy of the value in the `.data` section. They are fully independent after initialization - assigning to `a` does not affect `b` or `c`.

## Local variables

```pas
procedure Foo;
var
  la, lb, lc: integer = 10;
begin
  // la=10, lb=10, lc=10
end;
```

All variables share a single internal default-value symbol. The compiler generates an assignment from that symbol to each variable at procedure entry, just as it does for single-variable defaults.

## Typed constants

```pas
const
  MinX, MinY, MinZ: integer = 0;
  MaxX, MaxY, MaxZ: integer = 100;
```

Each constant gets its own storage in the constant data section (or read-only section when `{$J-}` is active). Record and array typed constants work too:

```pas
type
  TPoint = record x, y: integer; end;

const
  Origin, Default: TPoint = (x: 0; y: 0);
```

## Inline variables with explicit type

Requires `{$modeswitch inlinevars}` (on by default in unleashed mode).

```pas
procedure Bar;
begin
  var p, q: integer := 99;
  writeln(p, ' ', q); // 99 99
end;
```

The expression is evaluated once into a compiler-generated temporary, then assigned to each variable. This means a function call in the initializer executes only once:

```pas
var a, b: integer := ComputeValue; // ComputeValue called once
```

## Inline variables with type inference

```pas
procedure Baz;
begin
  var i, j   := 10;    // both LongInt
  var s1, s2 := 'hello'; // both String
end;
```

The type is inferred from the expression and applied to all variables. Standard promotions apply: sub-32-bit integers promote to `LongInt`, character literals promote to `String`.

## Semantics

### Value copy, not aliasing

Every variable receives an independent copy of the initial value. After initialization, the variables are completely unrelated:

```pas
var a, b: integer = 1;
a := 42;
// b is still 1
```

### Expression evaluation

| Context                    | Evaluation                                        |
|----------------------------|---------------------------------------------------|
| `var` section (global/local) | Parsed once at compile time as a typed constant  |
| `const` section            | Parsed once at compile time per variable (token replay) |
| Inline `var` with `:=`    | Evaluated once at runtime, assigned to each variable |

### Compatibility with single-variable syntax

When only one variable is listed, behavior is identical to standard Free Pascal. The modeswitch adds no overhead and changes no existing semantics.

## Limitations

- Thread variables (`threadvar`) cannot have initializers (same as standard FPC).
- The initializer must be a valid typed constant expression for `var` and `const` sections. Runtime expressions are only allowed in inline `var` declarations.
- `absolute` and `external` directives remain single-variable only.

## IDE support

Lazarus CodeTools recognize the multi-variable syntax in `const` sections. Code completion resolves the type for all variables in the list, so `pp.{Ctrl+Space}` shows record fields when `pp` is part of a multi-variable typed constant declaration.
