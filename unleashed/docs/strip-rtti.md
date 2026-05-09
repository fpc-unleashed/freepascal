# Strip RTTI

Replaces type-name shortstrings emitted into RTTI / VMT structures with empty strings, so an ASCII dump of the binary no longer reveals the program's internal type structure.

Feature gated by modeswitch `STRIPRTTI`, **off by default** in `{$mode unleashed}` - opt-in only.

```pas
{$mode unleashed}
{$modeswitch striprtti}
```

The modeswitch works **per-unit**: enable it in the units you want to harden, leave it off in units that need RTTI to function (forms, code that walks RTTI, units passed to `application.createform(...)`).

## Why

RTTI carries plain ASCII type names so that runtime introspection (`object.ClassName`, `Application.CreateForm(TForm1, ...)`, serializers, RPC frameworks, etc.) can find a type by string. Those strings are visible to anyone running `strings binary.exe`. For some programs that is a leak you would rather not give away - the most obvious example being security-sensitive software where embedding type names like `TGameAimbot` or `TLicenseChecker` in the binary tells a reverse engineer where to start.

Strip RTTI does not remove the RTTI structures themselves (they are still walked by Free, ClassName, finalization code, etc.) - it only nulls the **string content** of the type-name fields. Code that walks RTTI by structure still works; code that compares names against constants does not.

## What gets stripped

When `striprtti` is active, the following shortstrings are nulled:

| Source | What it is | Stripped |
|---|---|---|
| RTTI header (`write_header`) | Type name in the `TTypeInfo` block | yes |
| Object/class RTTI (`write_objectdef_rtti`) | Class real name (`def.objrealname`) | yes |
| Class VMT (`ncgvmt`) | Class name in the VMT (`_class.RttiName`) | yes |
| Member RTTI (`write_member_rtti`) | Field/property/method name (`sym.realname`) | yes |
| Used-units list | Module name in the units-of-use list (`hp.realname`) | yes |
| Module name (multiple sites) | `current_module.realmodulename^` written into class/interface/object RTTI | yes |
| Parameter names | Method parameter names in published method RTTI | yes |
| Type alias name | The `prettyname` written by `write_rtti_data_singleref` for an alias | yes |

The following are **not** stripped (intentionally):

| Source | Why |
|---|---|
| Interface GUID string (`def.iidstr^` for `odt_interfacecorba`) | Functional - COM dispatch and `IUnknown.QueryInterface` look it up by string. Stripping breaks COM. |
| Format strings, `writeln` arguments, RTL string constants | These are not RTTI - they are program data. |
| Symbol names exposed to the linker | Linker-visible symbols are governed by smart-linking and `{$L+}`, not by RTTI stripping. |

## Whitelisting

Three ways to keep specific types' names visible. All three set the same flag (`df_expose_rtti`) on the `tdef` during type parsing, so the cost of matching is paid once per declaration, not per RTTI emit.

### 1. `expose` keyword

A contextual keyword in `{$mode unleashed}`, placed immediately before a type name in a `type` block. Applies only to that one declaration.

```pas
{$mode unleashed}
{$modeswitch striprtti}

type
  TInternal = class(TObject)        // stripped
    ...
  end;

  expose TForm1 = class(TForm)      // kept - fingerprinted in binary
    ...
  end;

  expose TPoint = record            // works on records too
    x, y: integer;
  end;

  expose TColor = (red, green, blue); // and on enums, sets, ranges, aliases...
```

The keyword is gated on `m_unleashed`, not on `m_strip_rtti`. That means:

- In any other mode, `expose` is a regular identifier - existing code with a field, variable, or routine called `expose` keeps compiling.
- In `{$mode unleashed}`, `expose` is reserved even if `striprtti` is off. The keyword is parsed and the flag is set on the `tdef`; with `striprtti` off, nobody reads the flag, so it is a no-op. This is intentional - you can temporarily disable `striprtti` for a debug build without hitting "syntax error" on every `expose` line.

### 2. `{$rttiexpose}` directive (per-unit)

A list of glob patterns that whitelist types **declared in the current unit**. Patterns can be separated by whitespace, comma, or `, ` (with trim).

```pas
{$mode unleashed}
{$modeswitch striprtti}

{$rttiexpose TForm* TButton*}
{$rttiexpose TPanelMain, TLabelTitle}    // can appear multiple times, accumulates

type
  TForm1     = class(TForm) ...   // matches `TForm*` -> kept
  TButtonOK  = class(TButton) ... // matches `TButton*` -> kept
  TInternal  = class(TObject) ... // no match -> stripped
```

The patterns are stored on `tmodule` and consulted only while parsing types in that unit. They do not propagate to other units.

### 3. `--rttiexpose=` CLI flag (global)

A global list of glob patterns applied to every compiled unit. Repeatable - each `--rttiexpose=` appends to the list.

```
fpc --rttiexpose=TForm*,TButton* --rttiexpose=TPanelMain my_app.lpr
```

The CLI is the right place for whitelisting types you do **not** control, e.g. LCL or RTL classes that you cannot annotate with `expose` and whose source units you do not want to edit. A typical Lazarus build with stripping enabled looks like:

```
--rttiexpose=TForm*,TFrame*,TDataModule*,TButton*,TPanel*,TLabel*,TEdit*,TMemo*
```

### Merge semantics

The CLI list and the per-unit list are **merged** (union) when matching. The per-unit directive can only **widen** the whitelist for its own unit - it cannot remove types that the CLI already whitelisted. This is intentional: the CLI represents global build configuration that should not be silently overridden by a single unit.

A type matches if any of the following is true:

- it has the `expose` keyword in front of its declaration, **or**
- its name matches any pattern in the CLI list (`cli_rtti_expose_patterns`), **or**
- its name matches any pattern in the current unit's directive list (`current_module.rtti_expose_patterns`).

Patterns are case-insensitive. The match runs **once per type, at parse time**, and the result is stored as `df_expose_rtti` on the `tdef`. RTTI emit later just consults the flag - no per-emit pattern matching.

## Glob patterns

`*` matches zero or more characters. No other wildcards.

| Pattern | Matches |
|---|---|
| `TForm` | exactly `TForm` |
| `TForm*` | `TForm`, `TForm1`, `TFormMain`, `TFormFooBar` |
| `*Form` | `TForm`, `MyForm`, `XForm` |
| `T*Form` | `TForm`, `TMyForm`, `TBaseForm` |
| `*` | every type |

Comparisons are case-insensitive (patterns are lowercased on insertion, names lowercased before match).

## Side effects

Compiling LCL or anything that walks RTTI by string with `striprtti` on will likely brick the program at startup, because code such as:

```pas
Application.CreateForm(TForm1, Form1);
```

resolves `TForm1` against the resource section by **string** comparison. With `striprtti` and no whitelist, the compiler emits `''` for the type name - so the lookup looks for `""` and fails.

The fix is one of:

- whitelist the affected types (preferred): `--rttiexpose=TForm*,TFrame*,TDataModule*` or `expose TForm1 = class(...)` per declaration,
- enable `striprtti` only in units that do not need RTTI lookup (e.g. business-logic units, but not units containing forms),
- leave `striprtti` off for the whole project (default).

## Comparison

`my_app.exe` compiled three ways. Only strings produced by RTTI/VMT are shown - actual program data (`writeln('hello')`, error messages, etc.) is unaffected by `striprtti`.

```pas
program demo;
{$mode unleashed}

type
  TGameWallhack = class
    enabled: boolean;
  end;
  TGameAimbot = class
    targets: array of string;
  end;
  TLicense = class
    valid: boolean;
  end;

var c: TGameAimbot;
begin
  c := TGameAimbot.Create;
  writeln('hello');
  c.Free;
end.
```

| Build flags | RTTI strings in binary |
|---|---|
| (no flags) | `TGameWallhack`, `TGameAimbot`, `TLicense`, `demo` |
| `{$modeswitch striprtti}` | (none) |
| `{$modeswitch striprtti}` + `--rttiexpose=TGame*` | `TGameWallhack`, `TGameAimbot` |
| `{$modeswitch striprtti}` + `expose TLicense = class ...` | `TLicense` |

## Implementation notes

- Decision is encoded as `df_expose_rtti` on `tdef.defoptions` (set during parsing). RTTI emit reads it via the helper `rtti_string(s, def)` in `ncgrtti`.
- `rtti_string` returns `s` if `striprtti` is off **or** `df_expose_rtti` is set on `def`; otherwise returns `''`. Sites that emit a name without an associated `tdef` (module name, parameter name) call `rtti_string(s)` without `def` - they cannot be whitelisted by name.
- The flag is preserved across PPU - whitelisting decisions made in one compile run survive into binary form, so dependent units see the same `df_expose_rtti` state without re-running `--rttiexpose=` matching.
- Forward declarations (`type TFoo = class;`) - `expose` on the forward applies the flag to the same `tdef` that the final declaration completes, so both writes see it. `{$rttiexpose}` and `--rttiexpose=` match the name when the final declaration is parsed.
- Generic specialization - the flag follows the specialized def. If you `expose TList<T> = class ...`, every specialization (`TList<integer>`, `TList<string>`, etc.) inherits the flag.

## Notes

- `striprtti` is the renamed successor of an earlier `nortti` modeswitch. The mechanism was rewritten end-to-end (the old version had a global wildcard whitelist consulted at every emit site - now the decision is precomputed on the `tdef` and the helper is one if-statement).
- The modeswitch only nulls **string content**. The size of the RTTI block does not change - the compiler still emits a length-prefixed shortstring, just with length 0. So PPU layout, runtime walking code, and tools like `ppudump` keep working without adjustment.
