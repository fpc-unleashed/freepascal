# String Interpolation

Embed expressions inside a string literal using `$'...'` and `{expr}` placeholders. Each placeholder is type-checked, formatted, and concatenated with the surrounding text at compile time - no manual `+` chains, no `IntToStr()`, no hand-rolled `Format()` calls.

Modeswitch: `interpolatedstrings`, enabled by default in `{$mode unleashed}`; opt in elsewhere with `{$modeswitch interpolatedstrings}`.

## Basics

A `$` immediately before a string literal opens an interpolated string. Braces inside delimit Pascal expressions; everything else is text.

```pascal
var
  name := 'Alice';
  age := 30;
begin
  writeln($'Hello {name}, you are {age} years old.');
  // Hello Alice, you are 30 years old.
end.
```

The empty form is valid (`$''` evaluates to `''`). Any expression with a runtime printable form is allowed, including arithmetic and nested calls: `$'sum = {a + b * 2}'`.

The prefix works only on regular single-line `'...'` literals - neither `` $`...` `` nor `$'''` (see [multiline-strings.md](multiline-strings.md)) is accepted.

## Placeholder forms

| Form | Meaning |
|---|---|
| `{expr}` | auto-format by expression type |
| `{expr:mask}` | format via mask |

The mask begins at the first `:` after the complete expression; everything up to the closing `}` is the mask, taken verbatim - no quoting, no escaping, no space stripping. Colons *inside* the mask are fine (`{dt:hh:nn:ss}`). A `:` that belongs to the expression itself - e.g. inside a parenthesized `case` expression - is parsed as part of the expression and does not start a mask.

## Auto-dispatch (bare `{expr}`)

A bare placeholder is routed by the expression's type, first match wins:

| Expr type | Rendering |
|---|---|
| ordinal / float / string / boolean / char / enum | `WriteStr()` semantics: enums by identifier, booleans as `TRUE` / `FALSE`, floats in the default `WriteStr()` precision |
| static array | unrolled element list: `[e0, e1, ...]` |
| class reference (`TFoo` itself, not an instance) | `expr.ClassName` |
| class instance | `expr.ToString` (the `TObject` default returns the class name) |
| record / object instance with a `ToString()` method | `expr.ToString` (needs `advancedrecords`, default in unleashed) |
| record / class / object with a helper `ToString()` | the helper's `ToString()`, else the type name |
| anything else with a known type name | the type-name literal |
| anonymous unnamed type | compile error - name the type or use a `%`-mask |

Floats without a mask render in `WriteStr()`'s scientific default - for fixed decimals use a mask (`{f:0.00}` or `{f:%.2f}`). Scalars always take the `WriteStr()` path even when a helper `ToString()` for the type is in scope - the helper dispatch applies to structured types.

Limitations of the array row: only **static** arrays unroll. A dynamic array renders its type name instead (`TIntArr`, or `{Dynamic} Array Of LongInt` for an inferred one), and an open-array parameter currently renders as `[]` with the elements omitted - format those yourself.

## Format masks `{expr:mask}`

### Width masks - no SysUtils needed

A mask that is just a field width - a plain number containing a nonzero digit (`{x:6}`), optionally with fraction digits (`{r:8:2}`) - does not dispatch to any function. It lowers to the same width specifier `write(x:6)` / `write(r:8:2)` uses: right-pads anything `write` can pad (integers, floats, strings, chars, booleans), zero dependencies. An all-zero mask (`0`, `000`) is not a width - it keeps the `FormatFloat()` zero-padding meaning below.

### Function masks

Any other mask picks a runtime function from the expression type and the mask shape:

| Expr type | Mask shape | Dispatches to | Needs |
|---|---|---|---|
| any | starts with `%` | `Format(mask, [expr])` | `uses SysUtils` |
| `TDateTime` / `TDate` / `TTime` | non-`%` (e.g. `yyyy-mm-dd`) | `FormatDateTime(mask, expr)` | `uses SysUtils` |
| float (non-date/time) | non-`%` (e.g. `0.00`) | `FormatFloat(mask, expr)` | `uses SysUtils` |
| integer | `xN` / `XN` | `IntToHex(expr, N)` | `uses SysUtils` |
| integer | other numeric (`000`, `#,##0`) | `FormatFloat(mask, expr)` | `uses SysUtils` |
| string | non-`%`, non-width | compile error - use a width (`{s:40}`) or `%-40s` |
| record / enum / bool / ... | non-`%` | compile error - use `%s` or provide `ToString()` |

Integers reuse `FormatFloat()` for numeric masks, so `{n:000}` zero-pads and `{n:#,##0}` adds thousand separators. The value travels through `Extended`, so an `Int64` / `QWord` above 2^53 loses precision there - use a `%d` / `%.Nd` mask for those (full integer precision). Characters a `FormatFloat()` mask does not recognize pass through literally, so a typo'd mask renders verbatim rather than erroring.

```pascal
uses SysUtils;
var
  pi := 3.14159;
  n := 255;
  name := 'Alice';
begin
  // %-masks work for any type
  writeln($'pi = {pi:%.2f}');            // pi = 3.14
  writeln($'n hex = {n:%x}');            // n hex = FF
  writeln($'name = {name:%-10s}|');      // name = Alice     |

  // type-driven masks
  writeln($'pi = {pi:0.00}');                              // pi = 3.14
  writeln($'today = {EncodeDate(2026, 5, 4):yyyy-mm-dd}'); // today = 2026-05-04
  writeln($'n hex = {n:x4}');                              // n hex = 00FF
  writeln($'n pad = {n:00000}');                           // n pad = 00255
  writeln($'big = {1234567:#,##0}');                       // big = 1,234,567
end.
```

## Locale: invariant by default, `L` opts in

`FormatDateTime()` and `FormatFloat()` calls default to the **invariant locale** (English month / day names, `.` decimal separator, `,` thousand separator), so `{1234.5:0.00}` is `'1234.50'` on every machine. Prefix the mask with `L` to use `DefaultFormatSettings` (the system locale):

```pascal
writeln($'{1234.5:0.00}');     // 1234.50  (invariant, everywhere)
writeln($'{1234.5:L0.00}');    // decimal separator of the host locale
```

The `L` is consumed by the parser, not forwarded. `IntToHex()` takes no locale, so `L` is a no-op on `xN` masks.

## Escaping and nesting

| Source | Result |
|---|---|
| `''` inside `$'...'` outside `{...}` | literal `'` |
| `{{` / `}}` inside `$'...'` outside `{...}` | literal `{` / `}` |
| `'...'` inside `{...}` | ordinary Pascal string literal |
| `$'...{$'inner {x}'}...'` | nested interpolated string |

Inside `{...}` you are in a normal Pascal expression context, so a string literal uses single quotes, not doubled ones. The doubled-apostrophe escape applies only to the outer text:

```pascal
writeln($'It''s {name}');                   // It's Alice
writeln($'literal braces: {{ and }}');      // literal braces: { and }
writeln($'tag: {$'<{name}>'}');             // tag: <Alice>
```

A mask cannot contain `}` (there is no escape inside a mask). To render literal text shaped like a mask, put it outside the placeholder.

Padding note: `{name:40}` right-pads via the width path; left-alignment is a `Format()` job - `{name:%-40s}`.

## Diagnostics

| Situation | Message |
|---|---|
| Mask needs a function whose unit is not in scope | `String interpolation format requires function "FORMAT" in unit "SYSUTILS" - add it to uses clause` (names the exact function and unit) |
| Mask shape does not fit the expression type | `String interpolation format "0.00" is not supported for this type` |

## Demo

```pascal
program interp_demo;

{$mode unleashed}

uses SysUtils;

type
  TState = (stIdle, stBusy, stDown);

  TServer = record
    name: string;
    load: double;
    state: TState;
    function ToString: string;
  end;

function TServer.ToString: string;
begin
  result := $'{name} [{state}] load {load:0.00}';
end;

begin
  var up := 3;
  var total := 4;
  writeln($'cluster: {up}/{total} up ({up / total * 100:%.0f}%)');

  var s: TServer := (name: 'alpha'; load: 0.375; state: stBusy);
  writeln($'worst: {s}');

  var mem := 3_407_872;
  writeln($'mem: {mem:#,##0} bytes ({mem shr 20} MiB), hex {mem:x6}');
  writeln($'when: {EncodeDate(2026, 7, 29):yyyy-mm-dd}');
  writeln($'[{'right':12}|{'left':%-12s}]');
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
cluster: 3/4 up (75%)
worst: alpha [stBusy] load 0.38
mem: 3,407,872 bytes (3 MiB), hex 340000
when: 2026-07-29
[       right|left        ]
```
