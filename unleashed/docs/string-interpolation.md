# String Interpolation

Embed expressions inside a string literal using `$'...'` and `{expr}` placeholders. Each placeholder is type-checked, formatted, and concatenated with the surrounding text at compile time, so no manual `+` chains, `IntToStr`, or `Format` calls.

**Activate:** `{$mode unleashed}` (default), or `{$modeswitch interpolatedstrings}` from any other mode.

## Basics

A `$` immediately before a string literal opens an interpolated string. Curly braces inside delimit Pascal expressions; everything else is text.

```pas
var
  name: string = 'Alice';
  age: integer = 30;
begin
  WriteLn($'Hello {name}, you are {age} years old.');
  // Hello Alice, you are 30 years old.
end.
```

The empty form is valid: `$''` evaluates to `''`. Nested calls work: `$'sum = {a + b * 2}'`. Any expression that yields a value with a runtime printable form is allowed.

## Placeholder forms

Inside a placeholder you can use any of:

| Form              | Meaning                                                |
|-------------------|--------------------------------------------------------|
| `{expr}`          | auto-format expr (see [Auto-dispatch](#auto-dispatch)) |
| `{expr:mask}`     | format via mask (see [Format masks](#format-masks))    |

The mask begins at the first `:` that follows the complete expression; everything from there up to the closing `}` is the mask, taken verbatim - no quoting, no escaping, no spaces stripped. Colons *inside* the mask are fine (`{dt:hh:nn:ss}`). A `:` that belongs to the expression itself - for example inside a parenthesised `case`-expression - is parsed as part of the expression and does not start the mask, so no extra escaping is needed there.

## Auto-dispatch

A bare `{expr}` is routed by the type of the expression:

| Expr type                                | Handler                                               | Requires                                                                 |
|------------------------------------------|-------------------------------------------------------|---------------------------------------------------------------------------|
| ordinal / float / string / boolean / char / enum | passes through `WriteStr` (the outer interp builder) | -                                                                         |
| dynamic / open / static array            | unrolls into `'[', e0, ', ', e1, ..., ']'`            | -                                                                         |
| class reference (`TFoo`, not an instance)| `expr.ClassName`                                      | -                                                                         |
| class instance                           | calls `expr.ToString` if defined, else `typename`     | -                                                                         |
| record / object instance with ToString   | calls `expr.ToString`                                 | `{$modeswitch advancedrecords}` (default in `unleashed`)                  |
| record / class / object via type helper  | calls helper's `ToString` if defined, else `typename` | `{$modeswitch typehelpers}` + `{$modeswitch multihelpers}` (both default in `unleashed`) |
| anything else with a known type name     | compile-time string literal of the type name          | -                                                                         |
| anonymous unnamed type                   | error - give it a name or use `{expr:%s}`             | -                                                                         |

Booleans render as `TRUE` / `FALSE` (Pascal's `WriteStr` default). Enums render by their identifier. Floats render with `WriteStr`'s default precision - if you want a fixed number of decimals, use a mask: `{f:0.00}` or `{f:%.2f}`.

## Format masks

`{expr:mask}` dispatches to a runtime function picked from the expr type and the mask shape:

| Expr type                       | Mask shape                  | Dispatches to                | Requires                                |
|---------------------------------|-----------------------------|------------------------------|-----------------------------------------|
| any                             | starts with `%`             | `Format(mask, [expr])`       | `uses SysUtils` (provides `Format`)         |
| `TDateTime` / `TDate` / `TTime` | non-`%` (e.g. `yyyy-mm-dd`) | `FormatDateTime(mask, expr)` | `uses SysUtils` (provides `FormatDateTime`) |
| float (non-date/time)           | non-`%` (e.g. `0.00`)       | `FormatFloat(mask, expr)`    | `uses SysUtils` (provides `FormatFloat`)    |
| integer                         | `xN` / `XN`                 | `IntToHex(expr, N)`          | `uses SysUtils` (provides `IntToHex`)       |
| integer                         | any other (e.g. `000`, `#,##0`) | `FormatFloat(mask, expr)` | `uses SysUtils` (provides `FormatFloat`)    |
| string + non-`%` mask           | -                           | error (use `%-40s`)          | -                                       |
| other (record/enum/bool/...)    | non-`%` mask                | error (use `%s` / give a ToString) | -                                  |

Integers reuse `FormatFloat` for numeric masks, so `{n:000}` zero-pads, `{n:#,##0}` adds thousand separators, and `{n:0.00}` promotes to a fractional form - matching the way `0`/`#`/`,` masks read in other languages. The value goes through `Extended`, so an `Int64` / `QWord` above 2^53 loses precision; use a `%d` or `%.Nd` `Format` mask for those (those keep full integer precision). As with floats, characters a `FormatFloat` mask does not recognise pass through literally, so a typo'd mask renders verbatim rather than erroring.

The compiler emits a clear error pointing at the missing function and unit when the required unit is not in scope.

### Examples

```pas
uses SysUtils;
var
  pi: double = 3.14159;
  n: integer = 255;
  dt: TDateTime;
  name: string = 'Alice';
begin
  // Format-style mask works for any type
  WriteLn($'pi = {pi:%.2f}');                 // pi = 3.14
  WriteLn($'n hex = {n:%x}');                 // n hex = FF
  WriteLn($'name = {name:%-10s}|');           // name = Alice     |

  // Type-driven masks
  WriteLn($'pi = {pi:0.00}');                 // pi = 3.14
  dt := EncodeDate(2026, 5, 4);
  WriteLn($'today = {dt:yyyy-mm-dd}');        // today = 2026-05-04
  WriteLn($'n hex = {n:x4}');                 // n hex = 00FF
end.
```

## Locale: invariant by default, `L` opts in

The default for `FormatDateTime` and `FormatFloat` is the **invariant locale** (English month / day names, `.` decimal separator, `,` thousand separator). This means `{1234.5:0.00}` is `'1234.50'` regardless of the system the program runs on.

To use the system locale (`DefaultFormatSettings`), prefix the mask with `L`:

```pas
WriteLn($'{1234.5:0.00}');     // 1234.50  (invariant)
WriteLn($'{1234.5:L0.00}');    // 1234,50  (a locale with `,` as decimal separator)
```

The `L` prefix is consumed by the parser and not passed to the underlying function.

`IntToHex` does not take a locale argument so the `L` prefix is a no-op there.

## Escaping and nesting

| Source                                      | Result                       |
|---------------------------------------------|------------------------------|
| `''` inside `$'...'` outside `{...}`        | literal `'`                  |
| `{{` / `}}` inside `$'...'` outside `{...}` | literal `{` / `}`            |
| `'...'` inside `{...}`                      | normal Pascal string literal |
| `$'...{$'inner'}'`                          | nested interp string         |

Inside `{...}` you have a normal Pascal expression context, so a string literal uses single `'` (not doubled). The doubled-apostrophe escape applies only to the *outer* interpolation text.

```pas
WriteLn($'It''s {name}');                   // It's Alice
WriteLn($'literal braces: {{ and }}');      // literal braces: { and }
WriteLn($'tag: {$'<{name}>'}');             // tag: <Alice>
```

The mask after `:` is raw text terminated by `}`. It cannot itself contain a `}` (no escape). To include literal text that looks like a mask in the surrounding string, put it outside the placeholder.

## Diagnostics

| Code (`parser_e_interp_fmt_*`) | Meaning                                                                                                              |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------|
| `unit`                         | mask requires a function (e.g. `Format`) that is not in scope - the message names the function and its canonical unit |
| `bad_type`                     | the mask shape does not match the expression's type                                                                  |

## Comparing to other languages

If you arrived from another language, a few things are different:

- **C# / Python f-string** uses `{name,-40}` (alignment) or `{name:width}` for plain padding. Here padding lives inside the Format mask: `{name:%-40s}`.
- **C#** `{x:format}` IFormatProvider masks - closest equivalent is `{x:mask}` with the `L` locale prefix.
- **JavaScript / Kotlin** `${...}` with `$` before each placeholder. Here `$` is on the literal once (`$'...'`), and braces alone delimit placeholders inside.
