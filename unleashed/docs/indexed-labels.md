# Indexed Labels and Lazy Labels

Two extensions to `label` / `goto`. **Indexed labels** declare a whole family of labels under one name, keyed by ordinal values or strings, and jump to them by index - including a runtime index, which compiles to a case dispatch. **Lazy labels** drop the declaration requirement entirely: a `goto` to an undeclared name simply creates the label.

Availability:

- Indexed labels: every mode, whenever goto support is active (`{$goto on}` / `-Sg`; automatic in `{$mode unleashed}`). No modeswitch.
- Lazy labels: `{$mode unleashed}` only.

## Index spec forms

The bracket part of `label name[...]` is the index spec. It describes the set of keys the family covers:

| Spec | Declares |
|---|---|
| `label s[0..4];` | five labels, `s[0]` .. `s[4]` |
| `label s[1, 2, 3];` | three labels (value list) |
| `label s[0..10, 15];` | ranges and values mix: `s[0]` .. `s[10]` plus `s[15]` |
| `label s[byte];` | one label per value of the type: `s[0]` .. `s[255]` |
| `label s[boolean];` | `s[false]` and `s[true]` |
| `label s[mFast..mIdle];` | enum-keyed range |
| `label s['a'..'z'];` | char-keyed range |
| `label s[-5..5];` | negative indices are ordinary ordinals |
| `label s[0..3-1];` | constant expressions fold: `0..2` |
| `label s[LO..HI];` | named constants fold the same way |
| `label s[256..256];` | exactly one label, `s[256]` (degenerate range) |
| `label s['start', 'stop'];` | string-keyed family |
| `label s['only'];` | one string key |

Every ordinal key works: integers, enums, chars, booleans, subranges of any of them. A family declares one label symbol per covered index, so a huge span (`label s[0..1000000]`) costs compile time and memory proportional to its size - prefer declaring only what you use.

### A single bare value is an error

The one form the spec does not accept is a lone ordinal value:

```pascal
label s[256]; // Error: Single value not allowed as label index spec;
              // use a range "256..256", a value list of two or more
              // values, or an ordinal type
```

Next to `array[256] of T`, which declares 256 elements, `label s[256]` reads as "256 labels" - but an index spec is a set of values, so it would silently declare the single label `s[256]`. Instead of picking one meaning the compiler rejects the form and the error names both escapes: `s[256..256]` for one label with index 256, a range / value list / ordinal type for a family.

The check runs on the folded constant value, so no spelling of a single value gets through:

```pascal
label s[256];      // error: bare literal
label s[255+1];    // error: constant expression folding to one value
const IDX = 256;
label s[IDX];      // error: named constant
label s[mFast];    // error: single enum value - use s[mFast..mFast]
label s['x'];      // error: a single-character literal is a char,
                   // i.e. an ordinal - use s['x'..'x']
```

String keys are exempt: `label s['only'];` stays valid, a string can never be read as a count. Note the char gotcha in the last line above - `'x'` is a char literal, not a one-character string key, so it falls under the single-value rule (see [String keys](#string-keys)).

### Invalid specs

| Spec | Error |
|---|---|
| `label s[256];` | `Single value not allowed as label index spec; use a range "256..256", a value list of two or more values, or an ordinal type` |
| `label s[3..1];` | `High range limit < low range limit` |
| `label s[1..3, 2];` | `Duplicate identifier "s$2"` (index 2 declared twice) |
| `label s[string];` | `Ordinal expression expected` |
| `label s[n];` (variable) | `Constant Expression expected` |
| `label s[$100000000..$100000001];` | `The range of the array is too large` (bounds must fit in 32 bits) |
| `label s[byte, 300];` | `Illegal label declaration` (a type name closes the spec) |
| `label s['ab', 1];` | `Syntax error, "const string" expected but "ordinal const" found` |
| `label s[1, 'ab'];` | `Ordinal expression expected` |

The last two rows show that one family is either ordinal-keyed or string-keyed - the two key spaces never mix in one spec.

## Numeric ranges

```pascal
label state[0..4];

goto state[2];

state[0]: writeln('zero');
state[1]: writeln('one');
state[2]: writeln('two');
state[3]: writeln('three');
state[4]: writeln('four');
```

`label state[0..4]` declares five labels addressed as `state[0]` .. `state[4]`. As with plain labels, control falls through from one label to the next unless you jump away - the program above prints `two`, `three`, `four`.

## Value lists and mixes

```pascal
label steps[1, 2, 3];     // explicit value list
label mix[1..3, 7];       // ranges and values mix
label codes[200, 404];    // gaps are fine
```

A list needs two or more elements (one element is the single-value error above). Elements may combine freely, but the same index may appear only once: `label s[1..3, 2]` reports `Duplicate identifier "s$2"`.

## Whole ordinal types

Naming an ordinal type declares one label per value of that type:

```pascal
label bits[byte];         // bits[0] .. bits[255]
label flag[boolean];      // flag[false], flag[true]
label mode[TMode];        // one label per enum value
```

A type name closes the spec - nothing may follow it: `label s[byte, 300]` reports `Error: Illegal label declaration`. A type may however appear as the last element after values, so `label s[300, byte]` covers 300 plus `0..255`.

## Constant expressions and named constants

Indices are constant expressions everywhere - in the spec, in definitions, and in `goto`. All fold at compile time:

```pascal
const
  BASE = 3;
  LAST = 7;

label edge[0..3-1];            // 0..2
label step[0..2, LAST];        // 0..2 plus 7

goto step[BASE-1];             // direct jump to step[2], zero overhead
step[LAST]: writeln('lucky');  // defines step[7]
```

## Ordinal index types

Any ordinal type works as the key space - enums, chars and booleans included, with runtime dispatch available for all of them:

```pascal
type TMode = (mFast, mSlow, mIdle);

label handler[mFast..mIdle];

goto handler[mode]; // mode: TMode, runtime dispatch

handler[mFast]: ...
handler[mSlow]: ...
handler[mIdle]: ...
```

```pascal
label grade['a'..'c'];
goto grade[c];      // c: char

label f[boolean];
goto f[b];          // b: boolean

label sign[-1..1];
goto sign[n];       // negative indices dispatch like any other
```

## String keys

```pascal
label action['start', 'stop', 'reset'];

goto action['start'];

action['start']: writeln('starting');
action['stop']:  writeln('stopping');
action['reset']: writeln('resetting');
```

String keys are case-insensitive on both sides: `goto action['START']` jumps to `action['start']`, and `action['sTaRt']:` defines the same label as `action['start']:`. Only constant strings work - a string key is resolved entirely at compile time, and a `goto` with a string variable reports `Ordinal expression expected`.

Rules specific to string keys:

- A one-key list is fine: `label part['only'];`. The single-value error applies to ordinals only.
- A key needs at least two characters. A single-character literal (`'x'`) is a **char**, so it lands in the ordinal key space: `label s['x']` is the single-value error, `label s['x'..'z']` is a char range, and `label s['ab', 'x']` fails with `Syntax error, "const string" expected but "const char" found`.
- String and ordinal keys never mix in one family.
- String-keyed families never take a variable index - see the next sections.

## Defining and jumping

Every use of an indexed label - definition and `goto` alike - names one element. The bare family name is not a label:

```pascal
label state[0..4];

goto state;   // Error: Label "state" is an indexed label,
              // an index is required: "state[...]"
```

Definitions may cover any subset of the declared set. Each declared index that never gets a definition produces `Warning: Label not defined "state[3]"` - harmless when intentional, e.g. `label bits[byte]` with only a few defined targets.

A constant-index `goto`, however, must reach a defined label: `goto state[1]` with no `state[1]:` in the body reports `Error: Label used but not defined "state[1]"`.

Constant indices in `goto` fold at compile time to a direct jump with zero overhead - no table, no comparison.

## Variable index: runtime dispatch

When the index is a runtime value, the compiler generates a hidden case statement that jumps to the matching label:

```pascal
label state[0..4];
var n: integer;

n := 2;
goto state[n]; // lowered to: case n of 0: goto state[0]; ... end
```

Everything about the dispatch:

- It requires an explicit `label` declaration with an ordinal spec - range, list, type, or mix; gaps are fine (`label c[200, 404]` dispatches on a variable holding 200 or 404). Without a declaration the goto reports `Error: Label not found` - laziness cannot recover the target set.
- The dispatch covers the **defined** labels of the declared family. A runtime value with no matching defined label - outside the declared set, or inside it but never defined - jumps nowhere: execution simply continues at the statement after the `goto`.
- Any ordinal key space dispatches: integer, enum, char, boolean, negative ranges.
- String-keyed families never dispatch - their resolution is compile-time only.

Once a variable-index `goto` is generated, the family is frozen: defining a label outside the declared set after it (possible in `{$mode unleashed}` through lazy labels) reports `Error: Index 7 of label "state" is outside the range of an earlier "goto state[...]" with a variable index; declare the full range in the label declaration`. The already emitted dispatch could never reach the new target, so the compiler rejects it - declare the full range up front.

With optimizations enabled the dispatch compiles to a single jump through an address table whenever the declared range is dense. Plain `case` statements fall back to a compare chain when they have only a handful of branches; the dispatch is exempt from that size heuristic, so a small family does not need to be padded with unused labels to get the table.

## Lazy labels

In `{$mode unleashed}` a `goto` to an undeclared name creates the label on the spot - no `label` section needed:

```pascal
begin
  goto done;
  writeln('skipped');
  done:
  writeln('done');
end;
```

Constant-index gotos are lazy too; the first reference auto-declares the indexed family:

```pascal
goto step[1]; // auto-declares the indexed label family

step[0]: writeln('zero');
step[1]: writeln('one');
```

### Lazy labels and declared families

A declared family interacts with laziness in a precise way:

- **Definitions extend lazily.** With `label a[0..3]` in scope, `a[7]:` in the body is accepted and creates the label.
- **Forward constant gotos do not.** `goto a[7]` before `a[7]:` has been seen reports `Error: Identifier not found "A$7"` - within a declared family, a constant goto resolves against the labels that exist at that point. Once `a[7]:` has been defined, a later (backward) `goto a[7]` works.
- **The dispatch never extends.** A variable-index `goto a[n]` is built from the declared set only; lazily added indices are invisible to it (and defining them after the dispatch is the freeze error above).

### Lazy limitations

- A variable-index `goto name[n]` always requires an explicit `label name[...]` declaration - laziness cannot recover the target set needed to build the dispatch.
- String-keyed labels always require an explicit declaration with the key list.

Lazy labels follow the same scoping rules as declared ones: visible in the whole routine body.

## Errors and warnings

| Diagnostic | Trigger |
|---|---|
| `Error: Single value not allowed as label index spec; use a range "256..256", a value list of two or more values, or an ordinal type` | spec is one bare ordinal value (literal, constant expression, named constant, enum value, char) |
| `Error: High range limit < low range limit` | reversed range in the spec |
| `Error: Duplicate identifier "s$2"` | same index covered twice by one spec |
| `Error: Ordinal expression expected` | non-ordinal type as spec; ordinal element after a string key; string variable as goto index |
| `Error: Constant Expression expected` | variable in the spec |
| `Fatal: Syntax error, "const string" expected but "ordinal const" found` | ordinal element in a string-keyed spec |
| `Error: Label "s" is an indexed label, an index is required: "s[...]"` | bare family name used as label or goto target |
| `Error: Label used but not defined "s[1]"` | constant goto to a declared index with no definition |
| `Error: Label not found` | variable-index goto without a declaration |
| `Error: Identifier not found "S$7"` | forward constant goto outside the declared set |
| `Error: Index 7 of label "s" is outside the range of an earlier "goto s[...]" with a variable index; ...` | defining a new index after a variable-index goto froze the family |
| `Warning: Label not defined "s[3]"` | declared index never defined (harmless) |

## Demo

Every kind of label in one program: an enum-range family driven by a runtime dispatch, a range + value mix with constant folding, a value list with gaps, a whole-type family, char and negative ranges, a degenerate range, string keys, and lazy labels (plain and indexed).

```pascal
program indexed_labels_demo;

{$mode unleashed}

type
  TPhase = (phBoot, phRun, phShut);

const
  LAST = 7;

// enum-range family, variable-index goto: runtime dispatch over an enum
procedure phases;
label
  next, ph[phBoot..phShut];
var
  p: TPhase;
begin
  p := phBoot;
  next:
  goto ph[p];
  ph[phBoot]: write('boot ');  p := phRun;  goto next;
  ph[phRun]:  write('run ');   p := phShut; goto next;
  ph[phShut]: writeln('shutdown');
end;

// range + value mix; a named constant folds to a direct jump
procedure mix;
label step[0..2, LAST];
begin
  goto step[LAST];
  step[0]: write('s0 ');
  step[1]: write('s1 ');
  step[2]: write('s2 ');
  step[LAST]: writeln('jumped straight to step 7');
end;

// pure value list with gaps, runtime dispatch
procedure http(code: integer);
label c[200, 404];
begin
  goto c[code];
  writeln('unknown code');
  exit;
  c[200]: writeln('200 ok'); exit;
  c[404]: writeln('404 not found');
end;

// whole ordinal type as key space: one label per boolean value
procedure flag(b: boolean);
label f[boolean];
begin
  goto f[b];
  f[false]: writeln('flag off'); exit;
  f[true]:  writeln('flag on');
end;

// char range, runtime char index
procedure grade(c: char);
label g['a'..'c'];
begin
  goto g[c];
  g['a']: writeln('grade a'); exit;
  g['b']: writeln('grade b'); exit;
  g['c']: writeln('grade c');
end;

// negative indices are ordinary ordinals
procedure signum(n: integer);
label s[-1..1];
begin
  goto s[n];
  s[-1]: writeln('negative'); exit;
  s[0]:  writeln('zero');     exit;
  s[1]:  writeln('positive');
end;

// degenerate range: exactly one label, index 256
procedure single;
label only[256..256];
begin
  goto only[256];
  writeln('skipped');
  only[256]:
  writeln('single label 256');
end;

// string keys, case-insensitive
procedure report;
label part['head', 'body', 'foot'];
begin
  goto part['HEAD'];
  part['head']: writeln('== report ==');   goto part['body'];
  part['body']: writeln('all systems ok'); goto part['foot'];
  part['foot']: writeln('== end ==');
end;

// lazy labels: a plain label and an indexed family, no declarations
procedure lazy;
begin
  goto hop[1];
  hop[0]: write('hop0 ');
  hop[1]: write('hop1 ');
  goto fin;
  write('skipped ');
  fin:
  writeln('lazy done');
end;

begin
  phases;
  mix;
  http(404);
  flag(true);
  grade('b');
  signum(-1);
  single;
  report;
  lazy;
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
boot run shutdown
jumped straight to step 7
404 not found
flag on
grade b
negative
single label 256
== report ==
all systems ok
== end ==
hop1 lazy done
```
