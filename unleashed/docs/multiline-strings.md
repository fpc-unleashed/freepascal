# Multiline Strings

Two delimiter forms let a string literal span multiple source lines without manual `+` concatenation or `LineEnding` insertion. They share one modeswitch but differ in tokenization, indentation handling, and how they compose in expressions.

**Activate:** `{$mode unleashed}` (default), or `{$modeswitch multilinestrings}` from any other mode.

**Source of truth:** `compiler/scanner.pas:5670-5945` (`tscannerfile.readstringconstant`) and `compiler/scanner.pas:5593-5670` (`postprocessmultiline`).

## Backtick form `` `...` ``

A normal string literal extended to tolerate embedded newlines.

```pas
const
  empty   = ``;
  inline  = `single line`;
  banner  =
`========================================
=         FCF Fibonacci Demo           =
========================================`;
```

### Properties

- Opens with one `` ` `` and closes with one `` ` ``. A literal backtick inside the string is escaped by doubling: `` `` ``.
- Composes inline in expressions just like a regular literal:
  ```pas
  var s := `prefix-` + name + `-suffix`;
  WriteLn(`hello, `, name);
  if line.startsWith(`#`) then ...;
  ```
- Indent is **NOT** trimmed by default. Whatever whitespace sits inside the literal stays in the runtime value. Opt in with `{$MULTILINESTRINGTRIMLEFT}` (see below).

### When the scanner recognises it

The opening character `` ` `` immediately switches the literal into multi-line mode (`in_multiline_string := True`, `style := qsBacktick`). Newlines inside the literal are accepted; the literal ends only at the matching closing `` ` ``. Without the `multilinestrings` modeswitch, encountering `` ` `` raises `Illegal_Char`.

## Triple-quote form `'''...'''`

A Delphi-11-style textblock literal. The block is self-contained and the indent is auto-stripped.

```pas
const
  REPORT =
    '''
    sum     = %d
    largest = %d
    avg     = %.2f
    ''';
```

### Properties

- Opener: an odd count of three or more single quotes (`'''`, `'''''`, `'''''''`, ...) followed by a newline. The closing delimiter must match the opening count and sit on its own line of leading whitespace + that many `'`.
- Auto-trim is **mandatory and column-based**. The leading whitespace of the closing delimiter line defines the strip column. Every content line must start with at least that many whitespace characters; that exact prefix is removed from each line of the runtime value. A line with less indent triggers `scan_e_improperly_indented_multiline_string`.
- The block as a whole is one string value. It composes in expressions like any literal (assignment, function argument, return value), but you cannot put a `+` operator inside the block. To splice a variable into the middle, close the block, do the `+`, and reopen with a fresh `'''`:
  ```pas
  var s :=
    '''
    Hello,
    '''
    + name + ' (' + IntToStr(year) + ')'
    + '''

    Greetings.
    ''';
  ```

### When the scanner recognises it

Standard string scanning starts with `'`. If the scanner counts an odd number of consecutive single quotes greater than two and the next character is a newline, it switches into multi-quote mode:

```pas
else if (not backtick)
         and ((quote_count > 2) and ((quote_count mod 2) = 1))
         and (m_multiline_strings in current_settings.modeswitches) then
  begin
    style := qsMultiQuote;
    init_quote_count := quote_count;
    ...
  end
```

`quote_count` carries through to the closer, which must reproduce exactly that many `'`s on its own indent-only line for the literal to end.

## Companion directives

Both apply only inside a unit with `multilinestrings` active.

### `{$MULTILINESTRINGLINEENDING CR | LF | CRLF | PLATFORM | SOURCE}`

Selects the line-ending bytes baked into the literal at compile time. Applies to **both forms**.

| Value      | Effect                                                        |
|------------|---------------------------------------------------------------|
| `SOURCE`   | (default) keeps whatever the source file used                 |
| `CR`       | `#13` between every pair of lines                             |
| `LF`       | `#10`                                                         |
| `CRLF`     | `#13#10`                                                      |
| `PLATFORM` | the host's native ending (`#13#10` on Windows, `#10` on *nix) |

### `{$MULTILINESTRINGTRIMLEFT N | ALL | AUTO}`

Strip leading whitespace from each line of the literal. **Applies only to the backtick form** - the triple-quote form already trims based on its closing delimiter column.

| Value | Effect                                                              |
|-------|---------------------------------------------------------------------|
| `N`   | strip exactly `N` leading whitespace columns (0 .. 65535)           |
| `ALL` | strip every leading whitespace character on every line              |
| `AUTO`| strip up to the column of the opening backtick (mirrors triple-quote) |

```pas
{$MULTILINESTRINGLINEENDING LF}
{$MULTILINESTRINGTRIMLEFT AUTO}

const
  MSG =
       `line 1
        line 2
        line 3`;
//      ^^^^^^^^ trimmed because backtick was at column 8 and AUTO is on
```

## Picking a form

Both can be concatenated with `+`. The difference is what you have to write to get there.

- **Triple-quote** - prefer for indented in-source data blocks (SQL, templates, JSON) where you want the source to look natural and the runtime value to be flush-left. Splicing a variable mid-block requires closing the block, doing the `+`, and reopening with a fresh `'''`.
- **Backtick** - prefer when you want to splice expressions inline on a single line, when you need byte-exact control over indentation (no auto-trim by default), or when the value is short.

## Diagnostics

| Code                                          | Meaning                                                              |
|-----------------------------------------------|----------------------------------------------------------------------|
| `scan_f_unterminated_multiline_string`        | end-of-file or bad transition before the matching closing delimiter  |
| `scan_e_improperly_indented_multiline_string` | a triple-quote content line is indented less than the closing `'''`  |
| `scan_e_trimcount_out_of_range`               | `MULTILINESTRINGTRIMLEFT N` with `N` outside `0..65535`              |
| `scan_e_unknown_lineending_type`              | `MULTILINESTRINGLINEENDING` value not one of the listed identifiers  |
