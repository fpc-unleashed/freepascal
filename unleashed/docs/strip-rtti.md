# Strip RTTI

Replaces type-name shortstrings emitted into RTTI / VMT structures with empty strings, so an ASCII dump of the binary no longer reveals the program's internal type structure.

Feature gated by modeswitch `STRIPRTTI`, **off by default** in `{$mode unleashed}` - opt-in only.

```pas
{$mode unleashed}
{$modeswitch striprtti}
```

The modeswitch works **per-unit**: enable it in the units you want to harden, leave it off in units that need RTTI to function (forms, code that walks RTTI, units passed to `application.createform(...)`).

For a whole-project switch independent of per-unit modeswitches and immune to the modeswitch reset that a `{$mode X}` directive performs, pass the CLI flag `--striprtti`. The flag is checked by the same RTTI-emit path alongside the modeswitch (`rtti_string` short-circuits if either is active), so units that already opt-in via the modeswitch are unaffected and units that do not get hardened too.

```
fpc --striprtti -Tlinux app.pas
```

`--striprtti` has no effect on whitelisting: `expose`, `{$rttiexpose}` and `--rttiexpose=` keep working unchanged.

## Why

RTTI carries plain ASCII type names so that runtime introspection (`object.ClassName`, `Application.CreateForm(TForm1, ...)`, serializers, RPC frameworks, etc.) can find a type by string. Those strings are visible to anyone running `strings binary.exe`. For some programs that is a leak you would rather not give away - the most obvious example being security-sensitive software where embedding type names like `TGameAimbot` or `TLicenseChecker` in the binary tells a reverse engineer where to start.

Strip RTTI does not remove the RTTI structures themselves (they are still walked by Free, ClassName, finalization code, etc.) - it only nulls the **string content** of the type-name fields. Code that walks RTTI by structure still works; code that compares names against constants does not.

## What gets stripped

When `striprtti` is active, the following shortstrings are nulled:

| Source | What it is | Whitelist via `expose` |
|---|---|---|
| RTTI header (`write_header`) | Type name in the `TTypeInfo` block | on the type itself |
| Object/class RTTI (`write_objectdef_rtti`) | Class real name (`def.objrealname`) | on the class |
| Class VMT (`ncgvmt`) | Class name in the VMT (`_class.RttiName`) | on the class |
| Type alias name | The `prettyname` written by `write_rtti_data_singleref` | on the alias |
| Property name (typeinfo) | `sym.realname` for published property | on the owning class |
| Enum value names | `hp.realname` for each enum value | on the enum type |
| Procvar parameter names | `parasym.realname` in procvar RTTI | on the procvar type |
| Method parameter names (extended RTTI) | `para.realname` in extended method table | on the owning class |
| Published method name (VMT method table) | `tsym.realname` used by `MethodAddress` | on the owning class |
| Published method name (extended RTTI) | `sym.realname` in extended method entry | on the owning class |
| Published field name (VMT field table) | `tfieldvarsym.realname` used by `FieldAddress` | on the owning class |
| Published field name (extended RTTI) | `fldsym.realname` in extended field entry | on the owning class |
| Module name (RTTI structs) | `current_module.realmodulename^` in class/interface/object RTTI | (not whitelistable per type) |
| Module name (unit init/finalize table) | Used-unit names in the init/fini dispatch table | (not whitelistable per type) |
| Used-units list | Module name in the units-of-use list (`hp.realname`) | (not whitelistable per type) |

**Whitelist propagation:** the `expose` keyword on a type sets `df_expose_rtti` on its `tdef`. Members of an exposed type (its properties, enum values, procvar parameters, published methods/fields, and method parameters) inherit the whitelist - their names stay in the binary too. Without `expose` on the parent, members are stripped even if you want a single property name visible; this is by design (whitelist is a per-type opt-in).

The following are **not** stripped (intentionally):

| Source | Why |
|---|---|
| Interface GUID string (`def.iidstr^` for `odt_interfacecorba`) | Functional - COM dispatch and `IUnknown.QueryInterface` look it up by string. Stripping breaks COM. |
| String message handler names (`procedure foo; message 'bar';`) | Functional - runtime message dispatch (Cocoa, Symbian) uses the string for lookup. |
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

#### Where `expose` can be used

The keyword is a generic prefix: parser sets a boolean before reading the type, and the resulting `tdef` (whatever kind) gets `df_expose_rtti`. So `expose` works in front of every kind of type Pascal allows in a `type` block:

| Type kind | Example |
|---|---|
| class | `expose TForm1 = class(TForm) ... end;` |
| object | `expose TOldObj = object ... end;` |
| interface | `expose IFoo = interface ... end;` |
| record | `expose TPoint = record x, y: integer; end;` |
| class helper | `expose TStrHelper = class helper for string ... end;` |
| record / type helper | `expose THelp = record helper for integer ... end;` |
| enumeration | `expose TColor = (red, green, blue);` |
| subrange | `expose TDay = 1..7;` |
| set | `expose TColors = set of TColor;` |
| static array | `expose TBuf = array[0..15] of byte;` |
| dynamic array | `expose TIntArr = array of integer;` |
| pointer | `expose PNode = ^TNode;` |
| procedural / procvar | `expose TCallback = procedure(x: integer) of object;` |
| weak alias | `expose TMyInt = integer;` |
| strong alias | `expose TMyInt = type integer;` |
| generic | `expose generic TList<T> = class ... end;` |
| file type | `expose TLogFile = file of TRecord;` |

What gets kept depends on the type kind, because of the propagation rules - exposing a class keeps its property/method/field/method-param names; exposing an enum keeps its value names; exposing a procvar keeps its parameter names; exposing a record keeps the type name. See the propagation rules above.

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

Anything that walks RTTI by string and isn't whitelisted will fail at runtime. Concrete cases:

- **`Application.CreateForm(TForm1, Form1)`** - resolves `TForm1` against the resource section by string comparison. With `striprtti` and no whitelist, the type name is `''` and the lookup fails.
- **`SomeObject.MethodAddress('OnClick')`** - the VMT method table has empty names for stripped methods, so the lookup returns `nil`. LCL component event hookup uses this path during form streaming.
- **`SomeObject.FieldAddress('myButton')`** - same story for the VMT field table.
- **`GetPropInfo(SomeObject, 'Caption')`** - empty property names in extended RTTI, lookup fails.
- **`WriteStr(s, someEnumValue)` / `ReadStr(s, someEnumValue)`** - empty enum value names produce empty output / fail to parse input.

The fix is one of:

- whitelist the affected types: `--rttiexpose=TForm*,TFrame*,TDataModule*` or `expose TForm1 = class(...)` per declaration,
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

- Decision is encoded as `df_expose_rtti` on `tdef.defoptions` (set during parsing). RTTI emit reads it via the helper `rtti_string(s, def, parent_def)` in `ncgrtti`.
- `rtti_string` returns `s` if `striprtti` is off **or** `df_expose_rtti` is set on `def` **or** on `parent_def`; otherwise returns `''`.
  - `def` is the type whose name is being emitted (used at type-name emit sites).
  - `parent_def` is the owning type for member strings: the class for a property/method/field name, the enum for an enum value, the procvar for a parameter name. This is how an `expose` on the parent propagates to its members.
  - Sites that emit a name without any associated `tdef` (module name in unit init/finalize table) pass neither - those are stripped unconditionally and not whitelistable per type.
- The flag is preserved across PPU - whitelisting decisions made in one compile run survive into binary form, so dependent units see the same `df_expose_rtti` state without re-running `--rttiexpose=` matching.
- Forward declarations (`type TFoo = class;`) - `expose` on the forward applies the flag to the same `tdef` that the final declaration completes, so both writes see it. `{$rttiexpose}` and `--rttiexpose=` match the name when the final declaration is parsed.
- Generic specialization - the flag follows the specialized def. If you `expose TList<T> = class ...`, every specialization (`TList<integer>`, `TList<string>`, etc.) inherits the flag.

## Notes

- `striprtti` is the renamed successor of an earlier `nortti` modeswitch. The mechanism was rewritten end-to-end (the old version had a global wildcard whitelist consulted at every emit site - now the decision is precomputed on the `tdef` and the helper is one if-statement).
- The modeswitch only nulls **string content**. The size of the RTTI block does not change - the compiler still emits a length-prefixed shortstring, just with length 0. So PPU layout, runtime walking code, and tools like `ppudump` keep working without adjustment.
