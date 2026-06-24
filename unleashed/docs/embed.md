# `$embedstr` / `$embedbytes` Directives

Embed the contents of a file into source code at compile time. Two directives, one per output type:

- **`$embedstr`** - the file becomes a `String`.
- **`$embedbytes`** - the file becomes an `array of byte`.

Both read the file as raw bytes and emit the encoded data at the directive site. They are directives, not modeswitches - always available regardless of `{$mode}`.

The name `embed` (rather than `include`) is deliberate: `{$include}` / `{$i}` splice another file in as *source code to be compiled*, whereas these directives bake a file in as *data*.

## Two forms each

Each directive comes in a 2-arg and a 1-arg form. The form is chosen by token count: two tokens (`NAME 'path'`) -> named constant, one token (`'path'`) -> bare value expression.

```pas
{$embedstr   NAME 'path'}   // const NAME: String = '...';
{$embedstr   'path'}        // bare String expression
{$embedbytes NAME 'path'}   // const NAME: array[0..N-1] of byte = (...);
{$embedbytes 'path'}        // bare [$xx,$yy,...] array literal
```

The path may be quoted with `'...'` or `"..."`, or left bare (no spaces inside). Path resolution matches `{$I}`:

- **absolute** path is used verbatim.
- **relative** path is searched in the current source file's directory, then the local includepath, then the global includepath.

## `$embedstr`

For a non-empty file, the 2-arg form emits a `const` whose initializer is the file bytes as concatenated Pascal string fragments:

```pas
const <name>: String =
'<printable run 1>'+#$nn+#$nn+'<printable run 2>'
+'<printable run 3>'+...;
```

The 1-arg form emits just the expression (no `const`, no `;`), usable anywhere a `String` value fits.

Bytes are classified at encode time:

- Printable ASCII (`$20..$7E` excluding `$27` apostrophe) goes into single-quoted runs.
- Everything else (control bytes, high-bit bytes, the apostrophe) is a `#$nn` escape; single-nibble values use the short form `#$n`.

Empty file: 2-arg emits `const <name>: String = '';`, 1-arg emits `''`.

```pas
program demo;
{$mode unleashed}
{$embedstr schema 'schema.json'}
begin
  WriteLn('schema bytes: ', length(schema));   // length = file size
  if {$embedstr 'banner.txt'} <> '' then        // inline, no temp const
    WriteLn({$embedstr 'banner.txt'});
end.
```

After compilation `schema` is a `String` whose bytes match the file byte-for-byte; `byte(schema[i])` gives byte `i-1` of the original.

## `$embedbytes`

The 2-arg form emits a typed `const` with a parenthesized initializer (standard Pascal array-init syntax):

```pas
const <name>: array[0..N-1] of byte =
($a,$bb,$4,$5,
$6,$7,$8);
```

`N` is the file size. The `0..N-1` range form is plain Pascal, so the emitted const compiles in every mode, not only `unleashed`.

The 1-arg form emits a bare array literal in square brackets:

```pas
[$a,$bb,$4,$5,
$6,$7,$8]
```

The bracket difference reflects how Pascal parses constructors per context:

- `(a, b, c)` is the parenthesized initializer used by typed `const` declarations.
- `[a, b, c]` is the inline array/set constructor used in expressions (function arguments, etc.) - it resolves to `array of byte` automatically when the surrounding context expects one.

Empty file: 2-arg emits `const <name>: array of byte = ();`, 1-arg emits `[]`.

Bytes are emitted in compact hex (`$X` for `0..$F`, `$XX` otherwise), broken across lines at about 64 characters for readability.

```pas
procedure SendFrame(const bytes: array of byte);
begin
  Stream.Write(bytes[0], length(bytes));
end;

begin
  SendFrame({$embedbytes 'frame.bin'});   // 1-arg, inline
end.
```

### `$embedbytes` and typed-const init

```pas
const data: array of byte = {$embedbytes 'data.bin'};   // NOT supported
```

This does not compile: Pascal's typed-const initialiser parses `(...)`, not the `[...]` the 1-arg form emits. Use the 2-arg form for named byte arrays:

```pas
{$embedbytes data 'data.bin'}
```

### `var x := {$embedbytes ...}` infers `array of LongInt`

```pas
var x := {$embedbytes 'data.bin'};   // x is `array of LongInt`, NOT `array of byte`
```

The 1-arg form is a bare `[$xx,...]` literal; for `var` with inferred type Pascal picks the default integer type (`LongInt` on x86_64) for the elements, regardless of value range. Symptom: `length(x)` is right but each element is 4 bytes, so `move(x[0], dest, length(x))` copies only every fourth byte. Workarounds:

```pas
{$embedbytes data 'path'}                            // 2-arg: array[0..N-1] of byte
var x: array of byte := {$embedbytes 'data.bin'};    // explicit annotation steers it
procedure foo(a: array of byte);
foo({$embedbytes 'data.bin'});                       // parameter type pins it
```

## Use cases

- Baking small fixed assets (icons, sprite atlases, fonts, schemas, templates) into a single-binary executable without a runtime file dependency.
- Compiled-in default configuration that always exists as a fallback.
- Generated lookup tables produced by an external tool, picked up at the next build without a generated `.pas` file.
- Byte-exact test fixtures, where compile-time embedding rules out "file missing at run time".

Use `$embedstr` when the consumer wants text / a buffer to `move` out of; `$embedbytes` when an API demands `array of byte` typing (binary protocols, hash inputs, decoder feed).

## Constraints and notes

- **2-arg forms** expand to a `const` declaration, so they must sit where a const declaration is valid: at unit / program scope (after `uses`), or anywhere a local `const` is accepted in unleashed mode.
- **1-arg forms** expand to a bare expression and must sit where a value of the matching type fits (function argument, comparison operand, RHS). No named binding - to reference the same data twice, use the 2-arg form.
- The data is baked into the binary at the directive site; no runtime file I/O and no dependency on the file at run time. Repointing the path requires recompilation.
- Large files inflate compile time (and the constant parse path); use sparingly for assets of significant size.

## Errors

| Trigger | Diagnostic |
|---|---|
| `{$embedstr}` / `{$embedbytes}` with no arguments | `Error: embedstr: missing arguments` / `Error: embedbytes: missing arguments` |
| File not found in absolute path or any search path | `Fatal: Cannot open include file "<path>"` |
| File cannot be opened (permissions, etc.) | `Fatal: Cannot open include file "<resolved-path>"` |

A bare `{$embedstr foo}` is read as the 1-arg form looking for a file named `foo`; if no such file exists, the fatal `Cannot open include file "foo"` fires (same message as any other missing path).
