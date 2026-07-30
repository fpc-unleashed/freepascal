# Strip RTTI

Replaces the type-name shortstrings emitted into RTTI / VMT structures with empty strings, so an ASCII dump of the binary no longer reveals the program's internal type names.

Modeswitch: `striprtti`, **off by default** in `{$mode unleashed}` - opt-in only.

```pascal
{$mode unleashed}
{$modeswitch striprtti}
```

The modeswitch works **per-unit**: enable it in the units you want to harden, leave it off in units that need RTTI to function (forms, code that walks RTTI by string, units passed to `Application.CreateForm`).

For a whole-project switch independent of per-unit modeswitches, pass the CLI flag `--striprtti`. The RTTI-emit path short-circuits if either the modeswitch or the flag is active, so opting in per unit and stripping globally compose. `--striprtti` has no effect on whitelisting - `expose`, `{$rttiexpose}`, and `--rttiexpose=` keep working unchanged.

```
fpc --striprtti -Tlinux app.pas
```

## Why

RTTI carries plain ASCII type names so that runtime introspection (`obj.ClassName`, `Application.CreateForm(TForm1, ...)`, serializers, RPC frameworks) can look a type up by string. Those strings are visible to anyone running `strings binary.exe`. For security-sensitive software that is a leak worth closing - embedding `TGameAimbot` or `TLicenseChecker` in the binary tells a reverse engineer where to start.

Strip RTTI does not remove the RTTI structures themselves (they are still walked by `Free()`, `ClassName()`, finalization code) - it only nulls the **string content** of the type-name fields. Code that walks RTTI by structure still works; code that compares names against constants does not.

## What gets stripped

When `striprtti` is active, these shortstrings are nulled (each whitelistable by `expose` on the listed type):

| Source | Whitelist via `expose` on |
|---|---|
| Type name in the `TTypeInfo` header | the type itself |
| Class real name and VMT class name | the class |
| Type alias name | the alias |
| Published property names | the owning class |
| Enum value names | the enum type |
| Procvar parameter names | the procvar type |
| Published method / field names (VMT and extended RTTI) | the owning class |
| Method parameter names (extended RTTI) | the owning class |
| Module name, used-units list | (not whitelistable per type - stripped unconditionally) |

**Not stripped** (intentional, because they are functional or not RTTI):

- Interface GUID strings - COM dispatch and `IUnknown.QueryInterface` look them up by string.
- String message handler names (`procedure foo; message 'bar';`) - runtime message dispatch uses them.
- Format strings, `writeln()` arguments, RTL string constants - program data, not RTTI.
- Linker-visible symbol names - governed by smart-linking, not by this switch.

**Whitelist propagation:** `expose` on a type sets `df_expose_rtti` on its `tdef`, and the type's members (properties, enum values, procvar parameters, published methods / fields, method parameters) inherit the whitelist - their names stay too. Without `expose` on the parent, members are stripped even if you only wanted one visible; the whitelist is a per-type opt-in.

## Whitelisting

Three mechanisms, all setting the same flag on the `tdef` at parse time (so matching runs once per declaration, not per RTTI emit).

### 1. `expose` keyword (per declaration)

A contextual keyword in `{$mode unleashed}`, placed immediately before a type name:

```pascal
type
  TInternal = class(TObject) ... end; // stripped

  expose TForm1 = class(TForm) ... end; // kept - name in binary

  expose TPoint = record x, y: integer; end;           // works on records, enums,
  expose TColor = (red, green, blue);                  // sets, ranges, aliases,
  expose TCallback = procedure(x: integer) of object;  // procvars, etc.
```

The keyword is a generic prefix and works before every kind of type a `type` block allows: `class`, `object`, `interface`, `record`, class / record / type helper, enum, subrange, set, static / dynamic array, pointer, procedural / procvar, weak alias, strong alias, generic, and `file of T`. What stays depends on the kind, per the propagation rules above.

`expose` is gated on `m_unleashed`, **not** on `m_strip_rtti`:

- In other modes it is a regular identifier - existing code with a field, variable, or routine called `expose` keeps compiling.
- In `{$mode unleashed}` it is reserved even when `striprtti` is off, in which case it parses and sets the flag but nobody reads it (a no-op). That lets you disable stripping for a debug build without hitting a syntax error on every `expose` line.

### 2. `{$rttiexpose}` directive (per unit)

Glob patterns whitelisting types **declared in the current unit**, separated by whitespace or commas, accumulating across occurrences:

```pascal
{$rttiexpose TForm* TButton*}
{$rttiexpose TPanelMain, TLabelTitle} // accumulates
```

The patterns live on the module and apply only while parsing that unit - they do not propagate elsewhere.

### 3. `--rttiexpose=` CLI flag (global)

A global list applied to every compiled unit, repeatable:

```
fpc --rttiexpose=TForm*,TFrame*,TDataModule* my_app.lpr
```

This is the right place for types you do **not** control - LCL / RTL classes you cannot annotate and whose source you do not want to edit.

### Merge semantics

The CLI list and the per-unit list are **merged** (union). A per-unit directive can only **widen** the whitelist for its own unit - it cannot remove a type the CLI already whitelisted (the CLI is global build config that a single unit should not silently override). A type is kept if it carries `expose`, or its name matches any CLI pattern, or it matches any of its unit's directive patterns. Matching is case-insensitive, runs once per type at parse time, and the result is stored on the `tdef`.

## Glob patterns

`*` matches zero or more characters; no other wildcards.

| Pattern | Matches |
|---|---|
| `TForm` | exactly `TForm` |
| `TForm*` | `TForm`, `TForm1`, `TFormMain`, `TFormFooBar` |
| `*Form` | `TForm`, `MyForm`, `XForm` |
| `T*Form` | `TForm`, `TMyForm`, `TBaseForm` |
| `*` | every type |

## Side effects

Anything that walks RTTI by string and is not whitelisted breaks at runtime:

- `Application.CreateForm(TForm1, Form1)` - lookup by string fails (the type name is `''`).
- `obj.MethodAddress('OnClick')` - empty names in the VMT method table, returns `nil` (LCL form streaming uses this).
- `obj.FieldAddress('myButton')` - same for the field table.
- `GetPropInfo(obj, 'Caption')` - empty property names, lookup fails.
- `WriteStr(s, enumValue)` / `ReadStr(s, enumValue)` - empty enum value names produce empty output / fail to parse.

Fix by whitelisting the affected types, or enabling `striprtti` only in units that do not need RTTI lookup.

## Implementation notes

- The decision is `df_expose_rtti` on `tdef.defoptions`, set during parsing. RTTI emit reads it via `rtti_string(s, def, parent_def)`: returns `s` if stripping is off, or the flag is set on `def` or on `parent_def`; otherwise `''`. `parent_def` is what makes an `expose` on the parent propagate to member names.
- The flag survives PPU, so whitelist decisions in one compile carry into dependent units without re-running pattern matching.
- Only string *content* is nulled - the RTTI block keeps its size (a length-0 shortstring), so PPU layout, runtime walking, and `ppudump` keep working unchanged.
- Generic specializations inherit the flag from the exposed template.

## Demo

```pascal
program strip_demo;

{$mode unleashed}
{$modeswitch striprtti}

type
  TSecretEngine = class // stripped: name gone from the binary
    seed: integer;
  end;

  expose TPublicApi = class // whitelisted: name kept
    version: integer;
  end;

begin
  var e := TSecretEngine.Create;
  var p := TPublicApi.Create;
  writeln('engine=', e.ClassName, ' api=', p.ClassName);
  e.Free;
  p.Free;
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output - the stripped class has an empty `ClassName()`, the exposed one keeps it:

```
engine= api=TPublicApi
```

And `strings strip_demo.exe` finds `TPublicApi` but not `TSecretEngine`.

## See also

- [Custom binary metadata](binary-metadata.md) - `--fpcsignature=""` drops the compiler ident section, so combined with stripping the binary advertises neither the toolchain nor its type names.
