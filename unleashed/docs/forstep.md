# For-Step

`step N` clause in `for` loops to advance the counter by an arbitrary positive amount on each iteration. Works with both `to` and `downto`, and with inline `var`.

Feature gated by modeswitch `FORSTEP`, enabled by default in `{$mode unleashed}`.

## Basic use

```pas
for i := 1 to 10 step 2 do
  write(i, ' ');                   // 1 3 5 7 9

for i := 20 downto 1 step 3 do
  write(i, ' ');                   // 20 17 14 11 8 5 2

for var k := 5 to 50 step 5 do
  write(k, ' ');                   // 5 10 15 ... 50
```

The step expression must be ordinal and positive. Use `downto` for descending loops; the step itself is always positive (negative step is a parse error).

## Single evaluation

The step expression is evaluated **once** before the loop starts, so calls with side effects fire only one time:

```pas
for i := 0 to 12 step ComputeStep() do
  Use(i);                          // ComputeStep called exactly once
```

Same for the upper bound, the same way classic for already does.

## `step` is a context-sensitive keyword

`step` is **not** a reserved token. The scanner does not treat it as a keyword anywhere - the parser only checks for it in one position: right after the `to` / `downto` expression in a for-loop and before `do`. Anywhere else `step` stays an ordinary identifier:

```pas
var step: integer = 5;             // OK - step is a variable name

function step: integer;            // OK - step is a function name
begin Result := 7; end;

type TFoo = record step: integer end;   // OK - step is a record field

for i := 1 to step do Use(i);      // OK - upper bound is the variable `step`
                                   //      (parser already consumed it as part of hto)

for i := 0 to step step 1 do       // OK - first `step` is the upper bound,
  Use(i);                          //      second `step` is the keyword (= 1)
```

Lazarus' SynEdit highlighter mirrors this: only the keyword position lights up, not identifiers.

## Constant `step 1` folds back

A literal `step 1` is dropped in `simplify`, so the loop reverts to the regular for-loop code path and keeps every existing optimization (`do_loopvar_at_end`, range-check elision, unrolling, ...). Only `step N` for `N >= 2` (or any non-constant step) takes the dedicated path.

## Generated code

When `loopstep` survives `simplify`, `makewhileloop` emits a while-loop with the increment at the **start** of each iteration, guarded by a first-iteration flag:

```
steptemp := step;  totemp := to;  i := from;  first := true;
while true do begin
  if first then first := false
  else i := i + step;              // - step for downto
  if i > to then break;            // < to for downto
  body;                            // continue here lands on the next pass
end;
```

This shape lets every control-flow construct work the same as in a regular for loop:

- `continue` jumps to the always-true while-condition; the next pass runs the increment, then the range check, then the body. No infinite loop.
- `break` exits cleanly. The counter holds the value at break time (see [tweaks.md](tweaks.md), preserved for-loop counter).
- `exit` and `raise` propagate normally; no temporaries to clean up.

Cost: one bool temp plus one branch per iteration.

## Interaction with the preserved counter

The break check restores the last in-range value before exiting, so the counter holds the **last value the loop body actually saw**, not the overshoot:

```pas
for i := 1 to 10 step 4 do ;       // body runs at 1, 5, 9
{ i = 9 (the last value the body saw), not 13 }

for i := 1 to 10 step 3 do ;       // body runs at 1, 4, 7, 10
{ i = 10 (it lined up exactly) }

for i := 20 downto 1 step 4 do ;   // body runs at 20, 16, 12, 8, 4
{ i = 4 }
```

See [tweaks.md](tweaks.md) for the same guarantee on classic for-loops.

## Type rules

The step expression must be ordinal. The compiler picks the largest of `step.resultdef` and the loop variable's range type and uses that for the increment arithmetic.

| Loop variable type     | Allowed step types       |
|------------------------|--------------------------|
| `integer` / `int64`    | any integer              |
| `byte` / `word` / etc. | any integer              |
| `char`                 | `char` literal (`#2`) or `Chr(N)` |
| enum                   | enum value or its `Ord` representation |

Mixing `step 2` with `for c: char := 'a' to 'z'` requires a `Chr` cast or a `char`-typed expression (`step Chr(2)`); a plain integer step on a non-integer counter is rejected at parse time the same way `c := 5` would be.

## Errors

| Number | Identifier                          | Trigger                                       |
|--------|-------------------------------------|-----------------------------------------------|
| 03382  | `parser_e_for_step_must_be_positive`| `step 0` or `step -N` (constant)              |
| 03383  | `parser_e_for_step_not_ordinal`     | step expression is real / string / pointer   |
| 03384  | `parser_e_step_not_allowed_in_for_in`| `step` after a `for ... in` collection       |

For-in loops reject `step` outright with a dedicated diagnostic instead of the generic "DO expected".

## Edge cases

| Case                                        | Behavior                                                |
|---------------------------------------------|---------------------------------------------------------|
| `for i := 1 to 5 step 100 do`               | body runs once (`i = 1`), then `1 + 100 > 5` exits      |
| `for i := 10 to 1 step 2 do`                | empty range, body never runs                            |
| `for i := 5 to 5 step 3 do`                 | single iteration (`i = 5`)                              |
| `step` on a runtime-zero variable           | infinite loop (no compile-time check possible). Use a constant where you can. |
| Nested for-step                             | each level keeps its own `step` and counter             |

## Want it off?

```pas
{$mode unleashed}
{$modeswitch forstep-}

var step: integer;
for i := 1 to 10 step 2 do ...;    // syntax error: "DO" expected, "step" found
                                   // - parser no longer recognizes the keyword
```
