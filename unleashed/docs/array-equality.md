# Array Equality

`=` and `<>` between two arrays compare them element by element: equal means same length and every pair of elements equal. Stock FPC either rejects the comparison (static arrays) or silently compares references (dynamic arrays); with this feature the operators mean what they read as.

```pascal
var a: array of integer := [1, 2, 3];
var b: array of integer := [1, 2, 3];

if a = b then writeln('same contents'); // true - different instances, equal elements
```

Availability: modeswitch `arrayequality`, on by default in `{$mode unleashed}`. The lowering also needs `arrayoperators` active (on by default in unleashed as well) - see [Enabling outside unleashed](#enabling-outside-unleashed) for the pitfall this creates in other modes.

## What compares equal

Two arrays are equal when their lengths match and elements compare equal pairwise, in order. Nothing else matters:

- **Bounds are ignored** - a static `array[1..3]` equals a static `array[0..2]` with the same contents; elements pair up from `low()` on each side.
- **Kind is ignored** - static, dynamic, open array parameter and literal all compare with each other freely.
- **Length is checked first.** Different lengths short-circuit to `false` without touching a single element.
- Elements are compared from the first index up, and the comparison stops at the first difference.

`a <> b` is exactly `not (a = b)`.

## Array kinds

Every pairing works; each side independently may be:

| Operand | Example |
|---|---|
| static array | `array[0..3] of integer`, any bounds, any ordinal index |
| dynamic array | `array of integer` |
| open array parameter | `procedure p(const a: array of integer)` |
| array literal | `[1, 2, 3]` |
| concatenation result | `head + tail = whole` (`+` from `arrayoperators`) |

```pascal
var base: array[0..3] of integer = (1, 2, 3, 4);
var probe: array of integer := [1, 2, 3, 4];

if base = probe then ...            // static vs dynamic: true
if probe = [1, 2, 3, 4] then ...    // vs literal: true

var head: array of integer := [1, 2];
var tail: array of integer := [3, 4];
if head + tail = [1, 2, 3, 4] then ... // concat feeds the comparison
```

## Literals

A comparison against an array literal is unrolled at compile time into a length check followed by per-element comparisons, short-circuited - if the length does not match, no element is read. Two literals compared with each other unroll into a chain of constant element comparisons; a length mismatch between two literals is a constant `false`.

```pascal
if probe = [1, 2, 99, 4] then ...   // length(probe) = 4, then probe[0] = 1, ...
if [1, 2] = [1, 2, 3] then ...      // constant false, lengths differ
```

## Nested and multidimensional arrays

Element comparison recurses, so arrays of arrays and multidimensional static arrays compare by their innermost elements:

```pascal
type TGrid = array[0..1, 0..1] of integer;

var ga: TGrid = ((1, 2), (3, 4));
var gb: TGrid = ((1, 2), (3, 4));

if ga = gb then ... // true: 2x2 elements pairwise equal
```

```pascal
type TIntArray = array of integer;

function eq(const lhs, rhs: array of TIntArray): boolean;
begin
  result := lhs = rhs; // open arrays of dynamic arrays
end;

eq([[1, 2], [3, 4]], [[1, 2], [3, 4]]) // true
```

## Element comparison

Each element pair is compared with the element type's own `=`:

- Ordinals, floats, chars, strings, pointers: the built-in operator.
- Records: a user-defined `operator =` must exist; without one the comparison reports `Error: Operator is not overloaded: "<record type trec>" = "<record type trec>"`.
- Mismatched element types are rejected at the element level: comparing `array of integer` with `array of string` reports `Error: Operator is not overloaded: "LongInt" = "AnsiString(0)"`.

```pascal
type
  trec = record
    i: integer;
  end;

operator =(const lhs, rhs: trec): boolean;
begin
  result := lhs.i = rhs.i;
end;

// arrays of trec now compare element by element through the operator
```

## Char arrays and strings

Comparing a char array with a string is not an element comparison - string operands take the string comparison path, which already worked in stock FPC and behaves as expected:

```pascal
var a: array[0..5] of char;
var s: string;

a := 'foobar';
s := 'foobar';
if a = 'foobar' then ...  // string comparison, true
if a = s then ...         // string comparison, true
```

String constants keep this behavior even though a string literal internally carries an array type - they are never routed through the element-by-element path.

## References vs contents

Only the comparison of two array operands changes meaning. Reference tests keep their stock semantics:

```pascal
var d: array of integer := [1, 2];
var e: array of integer := [1, 2];

if d = e then ...                     // true: element comparison
if d = nil then ...                   // false: stock reference test, unchanged
if pointer(d) = pointer(e) then ...   // false: reference identity, the escape hatch
```

## Enabling outside unleashed

In `{$mode unleashed}` everything is on. In other modes **both** switches are needed:

```pascal
{$mode objfpc}{$H+}
{$modeswitch arrayoperators}
{$modeswitch arrayequality}
```

The trap: `{$modeswitch arrayequality}` alone changes nothing, and the failure mode differs by array kind - static arrays still refuse to compare (`Error: Operator is not overloaded`), but dynamic arrays **silently fall back to reference comparison**, so `a = b` compiles and returns `false` for two distinct instances with equal contents. Always enable `arrayoperators` alongside.

## Errors

| Diagnostic | Trigger |
|---|---|
| `Error: Operator is not overloaded: "Array[0..1] Of LongInt" = "Array[0..1] Of LongInt"` | static array comparison without the feature active |
| `Error: Operator is not overloaded: "<record type trec>" = "<record type trec>"` | element type is a record with no `operator =` |
| `Error: Operator is not overloaded: "LongInt" = "AnsiString(0)"` | element types do not match |

## Demo

```pascal
program array_equality_demo;

{$mode unleashed}

type
  TGrid = array[0..1, 0..1] of integer;

var
  base: array[0..3] of integer = (1, 2, 3, 4);
  probe: array of integer;
  head, tail: array of integer;
  ga: TGrid = ((1, 2), (3, 4));
  gb: TGrid = ((1, 2), (9, 4));
  seen, expected: array of string;

begin
  probe := [1, 2, 3, 4];
  writeln('static vs dynamic:  ', base = probe);

  probe[2] := 99;
  writeln('after a change:     ', base = probe);

  writeln('vs a literal:       ', probe = [1, 2, 99, 4]);

  head := [1, 2];
  tail := [3, 4];
  writeln('concat vs whole:    ', head + tail = [1, 2, 3, 4]);

  writeln('grids equal:        ', ga = gb);
  gb[1, 0] := 3;
  writeln('after fixing gb:    ', ga = gb);

  seen := ['alpha', 'beta'];
  expected := ['alpha', 'beta'];
  writeln('string elements:    ', seen = expected);
  writeln('inequality works:   ', seen <> ['alpha', 'gamma']);
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
static vs dynamic:  TRUE
after a change:     FALSE
vs a literal:       TRUE
concat vs whole:    TRUE
grids equal:        FALSE
after fixing gb:    TRUE
string elements:    TRUE
inequality works:   TRUE
```
