# `$incfile` Directive

Embed the contents of a file into source code at compile time as a Pascal string constant. The file is read as raw bytes, encoded into a sequence of printable-ASCII string fragments and `#$nn` byte escapes, and emitted at the directive site.

```pas
{$incfile NAME 'path'}
```

This is a directive, not a modeswitch - it is always available regardless of `{$mode}`. The encoded constant is placed exactly where the directive appears, so the directive must sit at a position where a declaration is valid.

## Syntax

```
{$incfile <varname> '<path>'}
```

- `<varname>` - a Pascal identifier; becomes the name of the emitted constant.
- `<path>` - file path, single- or double-quoted. Resolution rules match `{$I}`:
  - **absolute** path is used verbatim.
  - **relative** path is searched in the current source file's directory, then in the local includepath, then in the global includepath.

The path may contain spaces if quoted.

## What it emits

For a non-empty input file, the directive emits a `const` declaration whose initializer is the bytes of the file, concatenated as Pascal string fragments:

```pas
const <varname>: String =
'<printable run 1>'+#$nn+#$nn+'<printable run 2>'
+'<printable run 3>'+...;
```

Bytes are classified at encode time:

- Printable ASCII (`$20..$7E` excluding `$27` apostrophe) goes into single-quoted runs.
- Everything else (control bytes, high-bit bytes, the apostrophe) is emitted as a `#$nn` escape; single-nibble values use the short form `#$n`.

For an empty file, the directive emits `const <varname>: String = '';`.

The output is broken into source lines at about 64 characters wide, joined by `+`, purely for readability of the generated text.

## Examples

Embed a small JSON schema next to the source:

```pas
program demo;
{$mode unleashed}
{$incfile schema 'schema.json'}
begin
  WriteLn('schema bytes: ', length(schema));
end.
```

Embed a binary asset:

```pas
{$incfile icon 'assets/app.ico'}
```

After compilation `icon` is a `String` whose bytes match the file byte-for-byte; `length(icon)` equals the file size, and `byte(icon[i])` gives byte `i-1` from the original file.

Absolute path (no includepath lookup):

```pas
{$incfile big 'C:\projects\shared\preset.bin'}
```

## Use cases

- Baking small fixed assets (icons, sprite atlases, fonts, schemas, templates) into a single-binary executable without a runtime file dependency.
- Compiled-in default configuration that can be overridden at runtime but always exists as a fallback.
- Generated lookup tables produced by an external tool, picked up at the next build without a generated `.pas` file.
- Test fixtures that need to be byte-exact, where compile-time embedding rules out "file missing at run time" failure modes.

## Constraints and notes

- The directive expands to a Pascal `const` declaration, so it must sit where a const declaration is valid: at unit / program scope (after `uses`), or anywhere a local `const` is accepted in unleashed mode.
- In `{$mode unleashed}` and other FPC modes, a typed `const` initialised with a non-constant expression is writable by default unless `{$J-}` is in effect. If `{$J-}` is active and you need a writable buffer, copy the value into a `var`.
- The bytes are baked into the binary at the directive site; there is no runtime file I/O and no dependency on the file at run time. Repointing the path requires recompilation.
- Large files inflate compile time (and increase the constant string parse path); use sparingly for assets of significant size.

## Errors

| Trigger | Diagnostic |
|---|---|
| `{$incfile}` with no arguments | `Error: incfile: missing variable name and file path` |
| `{$incfile foo}` with no path | `Error: incfile: missing file path` |
| File not found in absolute path or any search path | `Fatal: Cannot open include file "<path>"` |
| File cannot be opened (permissions, etc.) | `Fatal: Cannot open include file "<resolved-path>"` |

All errors point at the directive's line.
