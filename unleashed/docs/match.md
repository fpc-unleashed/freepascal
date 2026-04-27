# Match Statement

Pattern matching with first-match semantics. Replaces `case...of` for non-ordinal types (tuples, strings, expressions) and adds fallthrough mode, condition-based matching, tuple wildcard patterns, and expression form.

Feature gated by modeswitch `MATCH`, enabled by default in `{$mode unleashed}`.

## Subject-based matching

```pas
match x of
  1: WriteLn('one');
  2: WriteLn('two');
  3: WriteLn('three');
end;
```

The subject expression is evaluated once, then compared against each branch value using `=`. First matching branch executes, rest is skipped.

## Catch-all: `_` and `else`

```pas
match x of
  1: WriteLn('one');
  _: WriteLn('other');
end;

match x of
  1: WriteLn('one');
else
  WriteLn('other');
end;
```

`_` is an unconditional catch-all branch. `else` works identically (with `statements_til_end` semantics, same as in `case`). `otherwise` is accepted as a synonym for `else`.

## String matching

```pas
match s of
  'hello': WriteLn('greeting');
  'bye':   WriteLn('farewell');
  _:       WriteLn('unknown');
end;
```

Unlike `case`, `match` supports strings as both subject and patterns.

## Comma-separated patterns

```pas
match x of
  1, 2, 3: WriteLn('small');
  4, 5, 6: WriteLn('medium');
  _:       WriteLn('big');
end;
```

Multiple values separated by commas are OR'd together.

## Condition-based matching (no `of`)

```pas
match
  x > 100: WriteLn('big');
  x > 10:  WriteLn('medium');
  x > 0:   WriteLn('small');
  _:       WriteLn('non-positive');
end;
```

Without `of`, each branch is a boolean expression. First true branch executes.

## Fallthrough: `match all`

```pas
match all x of
  5: WriteLn('five');
  5: WriteLn('also five');
  3: WriteLn('three');
  _: WriteLn('always');
end;
```

`match all` evaluates ALL matching branches (not just the first). Implemented as independent if-statements inside `repeat...until true`.

### `leave`

```pas
match all x of
  5: begin WriteLn('five'); leave; end;
  5: WriteLn('not reached');
  _: WriteLn('not reached');
end;
```

`leave` exits the `match all` block early (equivalent to `break`).

## Tuple patterns with `_` wildcards

```pas
match p of
  (0, 0): WriteLn('origin');
  (0, _): WriteLn('on Y axis');
  (_, 0): WriteLn('on X axis');
  _:      WriteLn('other');
end;
```

Tuple patterns are available in subject-based mode when the subject is a tuple type. `_` inside a tuple pattern skips that field (matches anything). Each non-wildcard field is compared with `=`, results are AND'd together.

`(_, _)` matches any tuple (all fields are wildcards).

## Match as expression

```pas
var s := match x of
  1: 'one';
  2: 'two';
  _: 'other';
end;
```

In expression form, each branch must produce a value. The result type is promoted across branches (same rules as `if` expression). Match expressions require exhaustive coverage (`_` or `else`).

Condition-based match works too:

```pas
var label := match
  x > 100: 'big';
  x > 10:  'medium';
  _:       'small';
end;
```

## Not in `match`

- `where` guards (removed; use condition-based mode or nested `if`)
- Range patterns (`1..10:`) - use condition-based mode
- Binding/capture of matched values
