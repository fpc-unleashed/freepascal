# Multiline Strings

Two delimiter forms let a string literal span multiple source lines without manual `+` concatenation or `LineEnding` insertion. They share one modeswitch but differ in tokenization, indentation handling, and how they compose in expressions.

Modeswitch: `multilinestrings`. Enabled by default in `{$mode unleashed}`, `{$mode objfpc}`, and `{$mode delphi}`; other modes (`fpc`, `tp`, ...) opt in with `{$modeswitch multilinestrings}`. Without it a backtick is rejected with `Illegal character "'`'" ($60)`.

Source of truth in the compiler: `tscannerfile.readstringconstant` and `postprocessmultiline` in `compiler/scanner.pas`.

## Backtick form `` `...` ``

A normal string literal extended to tolerate embedded newlines.

```pascal
const
  empty  = ``;
  inline = `single line`;
  banner =
`========================================
=              banner                  =
========================================`;
```

Properties:

- Opens with one `` ` `` and closes with one `` ` ``. A literal backtick inside the value is escaped by doubling (`` `` ``); an apostrophe needs no escape at all.
- Composes inline in expressions exactly like a regular literal:

  ```pascal
  var s := `prefix-` + name + `-suffix`;
  writeln(`hello, `, name);
  ```

- Indent is **NOT** trimmed by default. Whatever whitespace sits inside the literal stays in the runtime value. Opt in with `{$multilinestringtrimleft}` (below).

The opening `` ` `` immediately switches the scanner into multi-line mode; newlines inside are accepted and the literal ends only at the matching closing `` ` ``.

## Triple-quote form `'''...'''`

A textblock literal (the form Delphi 11 introduced). The block is self-contained and the indent is auto-stripped.

```pascal
const
  REPORT =
    '''
    sum     = %d
    largest = %d
    avg     = %.2f
    ''';
```

Properties:

- Opener: an odd count of three or more single quotes (`'''`, `'''''`, `'''''''`, ...) followed by a newline. The closer must reproduce exactly that many quotes on its own line of leading whitespace. The higher odd counts exist to embed runs of apostrophes verbatim: inside a 5-quote block, `''''` is literal text.
- Auto-trim is **mandatory and column-based**. The leading whitespace of the closing delimiter line defines the strip column; every content line must start with at least that much whitespace, and exactly that prefix is removed. A line with less indent reports `Incorrectly indented multi-line string (need N whitespace chars) starting at line L, column C.`
- The value is the content lines joined with the selected line ending, with **no trailing line ending** - `'''` on the next line after `ab` yields `'ab'`, not `'ab' + LineEnding`.
- The block as a whole is one string value and composes in expressions like any literal, but a `+` cannot appear inside the block. To splice a variable mid-text, close the block, concatenate, and reopen a fresh one:

  ```pascal
  var s :=
    '''
    Hello,
    '''
    + ' ' + name + `!`;
  ```

## Companion directives

Both apply only while `multilinestrings` is active.

### `{$multilinestringlineending CR | LF | CRLF | PLATFORM | SOURCE}`

Selects the line-ending bytes baked into the literal at compile time. Applies to **both forms**.

| Value | Effect |
|---|---|
| `SOURCE` | (default) keeps whatever the source file used |
| `CR` | `#13` between every pair of lines |
| `LF` | `#10` |
| `CRLF` | `#13#10` |
| `PLATFORM` | the target's native ending (`#13#10` on Windows, `#10` on Unix-likes) |

Pin this when the string's byte content matters (network protocols, checksums, tests) - otherwise the value silently follows the line endings your VCS happened to check the source out with.

### `{$multilinestringtrimleft N | ALL | AUTO}`

Strips leading whitespace from each line of the literal. **Applies only to the backtick form** - the triple-quote form already trims by its closing delimiter column.

| Value | Effect |
|---|---|
| `N` | strip exactly `N` leading whitespace columns (0..65535) |
| `ALL` | strip every leading whitespace character on every line |
| `AUTO` | strip up to the column of the opening backtick |

```pascal
{$multilinestringtrimleft AUTO}

const
  MSG =
       `line 1
        line 2
        line 3`;
// value: 'line 1' LE 'line 2' LE 'line 3' - indent up to the backtick column removed
```

## Picking a form

Both concatenate with `+`; the difference is what you write to get there.

- **Triple-quote** - prefer for indented in-source data blocks (SQL, templates, JSON) where the source should look natural and the runtime value flush-left. Splicing mid-block means close, `+`, reopen.
- **Backtick** - prefer for splicing expressions inline, for byte-exact control over indentation (no trim by default), or for short values.

## Interaction with string interpolation

The `$'...'` interpolated-string prefix works only with regular single-line `'...'` literals. Neither `` $`...` `` nor `$'''` is accepted - to combine a multiline block with computed values, use `Format()` over the block or splice with `+`.

## Diagnostics

| Situation | Diagnostic |
|---|---|
| EOF or bad transition before the matching closing delimiter | `Unterminated multi-line string` (fatal) |
| Triple-quote content line indented less than the closing `'''` | `Incorrectly indented multi-line string (need N whitespace chars) starting at line L, column C.` |
| `{$multilinestringtrimleft N}` with `N` outside 0..65535 | trim count out of range error |
| Unknown `{$multilinestringlineending}` value | unknown line ending type error |
| Backtick without the modeswitch | `Illegal character "'`'" ($60)` |

## Demo

```pascal
program multiline_demo;

{$mode unleashed}
{$multilinestringlineending LF}

uses SysUtils;

const
  BANNER =
`+----------------------------+
|      inventory report      |
+----------------------------+`;

  ROW =
    '''
    | %-16s | %7d |
    ''';

begin
  writeln(BANNER);
  writeln(Format(ROW, ['bolts', 240]));
  writeln(Format(ROW, ['nuts', 88]));
  writeln(`+----------------------------+`);
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
+----------------------------+
|      inventory report      |
+----------------------------+
| bolts            |     240 |
| nuts             |      88 |
+----------------------------+
```
