# Statement Expressions

Use `if`, `case`, and `try` as expressions that yield a value. The value is computed where it is consumed - no single-use temporaries, no `result := ...` branch dance.

Modeswitch: `statementexpressions`, enabled by default in `{$mode unleashed}`. Elsewhere:

```pascal
{$mode objfpc}
{$modeswitch statementexpressions}
```

(`match` has an expression form too - it lives with the rest of match in [match.md](match.md).)

## `if` expression

```pascal
var s := if x > 0 then 'positive' else 'non-positive';
```

Both branches are single expressions of compatible types; the `else` branch is required. Only the taken branch is evaluated - side effects in the other branch never fire:

```pascal
var s := if useCache then cached else loadFromDatabase;
// loadFromDatabase is called only when useCache is false
```

Chaining reads like a cascade:

```pascal
var s := if x > 100 then 'large' else if x > 10 then 'medium' else 'small';
```

## `case` expression

Two closing forms, picked by coverage:

**With `else`** - the `else` expression is the final token of the construct; there is **no** trailing `end`:

```pascal
var s := case day of
  1: 'Monday';
  2: 'Tuesday';
  3: 'Wednesday';
else
  'other';
```

**Exhaustive** - every value of the ordinal subject type is covered, no `else`, and the construct closes with `end`:

```pascal
var s := case flag of
  true:  'yes';
  false: 'no';
end;
```

Ranges and comma lists work exactly as in a `case` statement:

```pascal
var s := case x of
  0:    'zero';
  1..9: 'single digit';
else
  'large';
```

A string subject has no enumerable range, so string `case` expressions always require the `else` branch. An empty branch body (`'a': ;`) is rejected - every branch must be an expression.

## `try`-`except` expression

Evaluates the expression; if it raises, the fallback after `except` becomes the value:

```pascal
var s := try risky except 'fallback';

// with exception type filters and a final catch-all
var s := try risky except on e: EConvertError do 'convert error' else 'other error';
```

`try`-`finally` is not available as an expression - `try x finally ...` reports `Syntax error, "EXCEPT" expected but "FINALLY" found`.

## Type unification

All branches must yield compatible types; the result type unifies them with the same promotion rules as assignments:

```pascal
var s := if b then 'hello' else 'world';    // string
var i := case x of 1: 10; 2: 20; else 30;   // integer
var x := if b then 42 else 'hello';         // Error: Incompatible types
```

Numeric branches widen to a common type regardless of branch order - two integer branches take the smallest integer type covering both ranges, an integer branch mixed with a float branch promotes to the float:

```pascal
var big: int64 := 1 shl 40;

var a := if cond then 0 else big;      // int64-wide: holds big untruncated
var b := if cond then 3.5 else big;    // Double
var c := if cond then -1 else 100000;  // LongInt (covers both)
```

String-ish branches promote the same way: char + string gives string, mixed short / ansi / wide literals pick the wider carrier.

## Where they can appear

Anywhere an expression is expected:

```pascal
writeln(if b then 'yes' else 'no');                  // argument
arr[if i > 0 then i else 0] := value;                // array index
foo(case mode of 1: 'fast'; else 'slow');            // argument
var x := 1+(if b then 10 else 20);                   // sub-expression (parenthesize)
writeln($'{if score >= 60 then 'pass' else 'fail'}');// interpolation placeholder
```

## Every branch is a single expression

A branch is one expression - not a statement, not a block. Two consequences:

**No `begin..end` branches.** A branch cannot contain declarations or multiple statements; `if c then begin ... end else ...` in expression position reports `Illegal expression` at the `begin`. Hoist the work into a function (or compute the pieces in inline vars above the expression) when a branch needs more than one step.

**No value-less statements as branches.** `raise`, `exit`, `Halt()`, `break`, `continue`, `goto`, and bare procedure calls do not produce a value, so they are rejected (`Illegal expression`):

```pascal
// rejected: raise is a statement, not an expression
result := case n of
  1: 'one';
  2: 'two';
else
  raise Exception.Create('bad n');
```

For the "this should not happen" pattern keep the statement form:

```pascal
case n of
  1: result := 'one';
  2: result := 'two';
else
  raise Exception.Create('bad n');
end;
```

## Demo

```pascal
program statement_expr_demo;

{$mode unleashed}

uses SysUtils;

function parsePort(const s: string): integer;
begin
  result := try StrToInt(s) except 8080; // bad input collapses to the default
end;

begin
  for var score in [45, 71, 96] do begin
    var grade := case score of
      90..100: 'A';
      75..89:  'B';
      60..74:  'C';
    else
      'F';
    writeln($'score {score}: grade {grade}, {if score >= 60 then 'pass' else 'fail'}');
  end;

  writeln($'port "8123" -> {parsePort('8123')}');
  writeln($'port "oops" -> {parsePort('oops')}');
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
score 45: grade F, fail
score 71: grade C, pass
score 96: grade A, pass
port "8123" -> 8123
port "oops" -> 8080
```
