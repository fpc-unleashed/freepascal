# Inline Variable Declarations

Declare variables at the point of first use, inside statement blocks. Supports explicit types, type inference, and for-loop variables.

Feature gated by modeswitch `INLINEVARS`, enabled by default in `{$mode unleashed}`.

```pas
{$mode objfpc}
{$modeswitch inlinevars}
```

## Basic syntax

### Explicit type, no initializer

```pas
begin
  var x: integer;
  x := 42;
  writeln(x);
end;
```

### Explicit type with initializer

```pas
begin
  var x: integer := 42;
  writeln(x);
end;
```

### Aggregate initializers (array / record literals)

When the explicit type is a static array or record, the initializer may use the typed-constant aggregate syntax `(a, b, c)` / `(field: val; ...)`:

```pas
begin
  var a: array[1..3] of string := ('foo', 'bar', 'baz');
  var m: array[1..2, 1..2] of integer := ((1, 2), (3, 4));

  var p: record x, y: integer; end := (x: 7; y: 9);
end;
```

The initializer must be a compile-time constant expression, same rules as for classic typed constants. The aggregate is copied into the inline var at the point of declaration.

### Type inference

The type is deduced from the right-hand side of `:=`:

```pas
begin
  var x := 42;      // LongInt
  var s := 'hello'; // String
  var f := 3.14;    // Double
  var b := true;    // Boolean
end;
```

#### Type promotion rules

Small types are promoted to avoid surprising narrow ranges:

| Expression type                        | Inferred as                  |
|----------------------------------------|------------------------------|
| `Byte`, `ShortInt`, `Word`, `SmallInt` | `LongInt`                    |
| `Char`                                 | `String` (default string type) |

Explicit typecasts bypass promotion:

```pas
var b := Byte(10); // Byte, not LongInt
```

#### Array literal type inference

A bare `[...]` literal on the right-hand side of an inferred `var` yields a proper **dynamic array** (`array of T`). `T` is decided by the **first element**, regardless of what comes after; `nil` counts as a category that maps to `Pointer`.

| First element             | Inferred element type |
|---------------------------|-----------------------|
| string / char literal     | `AnsiString`          |
| integer literal           | `LongInt`             |
| float literal             | `Double`              |
| boolean literal           | `Boolean`             |
| enum value                | the enum type         |
| class instance            | the class type        |
| variant                   | `Variant`             |
| `nil`                     | `Pointer`             |

Every subsequent element must be assignable to the chosen `T`; mismatching literals are a compile error. For genuinely mixed-type collections use `array of Variant` explicitly, or pass through an `array of const` parameter.

Two diagnostic edge cases:

| Literal shape             | Default               | Diagnostic |
|---------------------------|-----------------------|------------|
| `[]` (empty)              | `array of AnsiString` | Hint       |
| `[nil, nil, ...]` (all nil) | `array of Pointer`  | Hint       |

`[nil, obj, obj]` (nil first, real values after) silently picks `Pointer` without a hint - the non-nil tail clearly signals the intent is a pointer container.

```pas
var a := ['', 'a', 'bb', 'longer'];        // array of AnsiString, all 4 elements kept fully
var c := [1, 2, 1_000_000];                // array of LongInt
var d := [3.14, 2.71];                     // array of Double
var e := [true, false];                    // array of Boolean
var pa := [nil, nil, nil];                 // array of Pointer (hint emitted)
var pb := [nil, TFoo.Create];              // array of Pointer (no hint, nil first)
var x := [];                               // array of AnsiString (hint: empty, defaulting)

// compile error: integer `1` cannot be assigned to inferred element type AnsiString
var bad := ['aaa', 1, 'bbb'];
```

Element category is what matters, not size: `[10, 200_000]` infers `array of LongInt` regardless of whether individual literals would fit in `Byte`. Without this rule the parser would silently emit a static array sized to the first element and truncate the rest. Use an explicit declaration if you need a different shape: `var fixed: array[0..2] of String := [...]`.

## For-loop variables

### for..to/downto with explicit type

```pas
for var i: integer := 0 to 9 do
  writeln(i);
```

### for..to/downto with type inference

```pas
for var i := 0 to 9 do // i is LongInt
  writeln(i);
```

The `from` expression determines the type. Sub-32-bit integers are promoted to `LongInt`, same as regular inline vars.

### for..in with explicit type

```pas
for var ch: char in 'hello' do
  writeln(ch);
```

### for..in with type inference

```pas
for var ch in 'hello' do  // ch is Char
  writeln(ch);

for var item in MyList do  // type from enumerator
  writeln(item);

for var s in ['abc', 'longer string'] do  // s is AnsiString
  writeln(s);
```

String literals in an array literal infer `AnsiString` for the loop variable, same as `var a := [...]` inference - every element is kept fully even when the first one is the shortest. Without this rule the variable would take the literal's carrier type sized to the first element and silently truncate the rest. Char literals keep `Char`.

#### Integer literal lists: set vs array

For an integer list the loop variable infers a common type wide enough for **every** element, not just the first one. What the loop iterates over depends on the values:

- all constant elements fit `0..255`: the literal stays a **set**, as in stock Pascal - iteration is ascending and duplicates are a compile error;
- any constant element is outside `0..255`: a set cannot hold it, so the literal iterates as an **array** - source order, duplicates allowed, no truncation.

```pas
for var n in [3, 1, 2] do        // set: iterates 1, 2, 3
  write(n, ' ');

for var n in [4, 1994, 3888] do  // array: iterates 4, 1994, 3888 in order
  write(n, ' ');                 // n is LongInt (wide enough for all)

for var n in [5000000000, 1] do  // Int64 elements work too
  write(n, ' ');
```

The same applies to a predeclared loop variable (`for n in [...]`). Outside unleashed mode the stock behavior is kept (byte set with range-check warnings and truncation).

## Scoping

### Block scoping (Delphi-style)

Variables declared inside a nested `begin..end` block are visible only within that block:

```pas
procedure Foo;
begin
  writeln('outer');
  begin
    var x := 10;
    writeln(x);  // OK
  end;
  // writeln(x); // Error: x not visible here
end;
```

The outermost `begin..end` of a procedure is **not** a nested block. Variables declared there have procedure-wide scope, same as variables in the `var` section.

### For-loop scoping

For-loop inline variables are scoped to the loop body:

```pas
for var i := 0 to 9 do
  writeln(i);
// i is not visible here
```

### No shadowing

Inline variables cannot shadow variables from enclosing scopes. This prevents subtle bugs where a nested block accidentally hides an outer variable:

```pas
procedure Foo;
var x: integer;
begin
  begin
    var x := 10; // Error: duplicate identifier
  end;
end;
```

This applies across all enclosing block scopes, parameters, and the procedure's own `var` section.

## Inline constants

`const` declarations work in statement blocks too, with the same block scoping as inline vars:

```pas
begin
  const K = 50;                          // true compile-time constant
  const S = 'hello';
  const T: Integer = 7;                  // typed constant (block-scoped storage)
  const A: array[3] of integer = (1, 2, 3);
  begin
    const Inner = K * 2;                 // visible only in this block
  end;
end;
```

The plain `const K = expr` form requires a compile-time evaluable expression and produces a true constant (not assignable, no storage). The typed form `const K: T = v` follows the usual typed-constant rules, including `{$J}` writability, but is scoped to the declaring block.

## Debugger support

Block-scoped inline variables emit proper DWARF debug information:

- Each `begin..end` block that contains inline vars gets a `DW_TAG_lexical_block` entry with `DW_AT_low_pc`/`DW_AT_high_pc` address ranges.
- Variables inside the block are children of the lexical block entry, so the debugger shows only variables visible at the current program counter.
- For-loop inline variables also get their own lexical block scope.
- The Lazarus IDE debugger correctly displays inline variables in the Local Variables panel, scoped to their enclosing block.

## Where inline vars can appear

Inline var declarations are valid wherever a statement is expected:

```pas
begin
  var x := 1;              // top of procedure
  if condition then
    begin
      var y := 2;          // nested block
    end;
  for var i := 0 to 9 do  // for loop
    writeln(i);
  while condition do
    begin
      var z := 3;          // while body
    end;
end;
```

They are **not** valid in:

- Unit `interface` or `implementation` sections outside procedures (use regular `var` sections for global variables).
- Class/record field declarations (use regular field syntax).

## Interaction with other features

### Statement expressions

Inline vars work inside statement expressions:

```pas
var result := if x > 0 then
  begin
    var temp := x * 2;
    temp + 1
  end
else
  0;
```

### Compound assignment operators

```pas
var x := 10;
x += 5; // with {$coperators on} or unleashed mode
```
