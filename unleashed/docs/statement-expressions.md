# Statement Expressions

Use `if`, `case`, and `try` as expressions that yield a value. Eliminates temporary variables for conditional assignment.

Feature gated by modeswitch `STATEMENTEXPRESSIONS`, enabled by default in `{$mode unleashed}`.

```pas
{$mode objfpc}
{$modeswitch statementexpressions}
```

## if expression

```pas
var s: string;
s := if x > 0 then 'positive' else 'non-positive';
```

Both branches must yield values of compatible types. The `else` branch is required.

### Multi-line with begin..end

When a branch needs multiple statements, use `begin..end`. The last expression in the block is the result:

```pas
var y := if x > 0 then
  begin
    var temp := x * 2;
    temp + 1
  end
else
  0;
```

### Nested

```pas
var s := if a then 'a'
         else if b then 'b'
         else 'c';
```

## case expression

```pas
var s: string;
s := case day of
  1: 'Monday';
  2: 'Tuesday';
  3: 'Wednesday';
  4: 'Thursday';
  5: 'Friday';
else
  'Weekend';
end;
```

Each branch yields a value. The `else` branch is required. All branches must yield compatible types.

## try-except expression

```pas
var s: string;
s := try SomethingRisky except 'fallback';
```

If the try-expression raises an exception, the except-expression is used instead.

### With exception type filters

```pas
s := try SomethingRisky
     except
       on e: EConvertError do 'convert error'
     else
       'other error';
```

The `else` clause handles any exception not matched by `on` filters.

### Syntax notes

- No `end` keyword after the except block (unlike statement-level try-except).
- A semicolon or the enclosing expression boundary terminates the construct.

## Type compatibility

All branches of a statement expression must yield compatible types. The compiler determines the result type from the branches using the same promotion rules as regular assignments:

```pas
// string + string = ok
var s := if b then 'hello' else 'world';

// integer + integer = ok
var i := case x of 1: 10; 2: 20; else 30; end;

// mismatched types = error
var x := if b then 42 else 'hello'; // Error
```

Numeric branches widen to a common type - the result holds every branch's value regardless of branch order. Two integer branches take the smallest integer type covering both ranges; an integer branch mixed with a float branch promotes to the float type:

```pas
var big: SizeInt = 311;

var a := if cond then 0 else big;    // Int64-wide, a = 311 (not truncated to 0's type)
var b := if cond then 3.5 else big;  // Double
var c := if cond then -1 else 100000; // LongInt (covers both)
```

String-ish branches promote the same way: char + string gives string, mixed short/ansi/wide literals pick the wider carrier.

## Where statement expressions can appear

Anywhere an expression is expected:

```pas
writeln(if b then 'yes' else 'no');

arr[if i > 0 then i else 0] := value;

Foo(case mode of 1: 'fast'; else 'slow'; end);

var x := 1 + (if b then 10 else 20);
```

## Every branch must yield a value

A statement expression is an **expression**, so each branch must produce a value of the result type. Statements that do not produce a value (`raise`, `exit`, `halt`, `break`, `continue`, `goto`, bare procedure calls, ...) are **not** allowed as a branch value:

```pas
// rejected: raise is a statement, not an expression
Result := case n of
  1: 'one';
  2: 'two';
else
  raise Exception.Create('bad n');
end;
```

The compiler reports `Illegal expression` at the `raise` token.

For the "this should not happen" pattern, use the regular case-statement and assign `Result` in the value-producing branches:

```pas
case n of
  1: Result := 'one';
  2: Result := 'two';
else
  raise Exception.Create('bad n');
end;
```

Same rule applies to `if`, `match`, and `try-except` expressions: every branch the expression can take has to evaluate to a value of the unified result type. A branch made up of statements with no final expression is an error.

## Other limitations

- `try-finally` is not supported as an expression (only `try-except`).
