# Custom Binary Metadata

Three CLI flags that override metadata fields the compiler embeds into the produced binary. All three default to the upstream value when not set; none of them changes generated code - runtime behavior is identical regardless.

| Flag | Field | Scope | Default |
|---|---|---|---|
| `--fpcsignature=<str>` | `.fpc.version` ident string | every target | `FPC Unleashed <version> [<date>] for <cpu> - <target>` |
| `--linkerversion=<Major.Minor>` | PE optional header `MajorLinkerVersion` / `MinorLinkerVersion` | Windows PE only | derived from the FPC version, e.g. `3.31` for FPC 3.3.1 |
| `--osversion=<spec>` | PE optional header `MajorOperatingSystemVersion` / `MinorOperatingSystemVersion` | Windows PE only | `4.0` unless `-WP<X>.<Y>` is set |

CLI-only; there is no directive form. These are build-level configuration ("what should this particular binary look like"), not source-level semantics.

## `--fpcsignature=<str>`

Replaces the ident string in the `.fpc.version` section of the produced object. The section is emitted by the compiler frontend for every target, so the flag works on Windows, Linux, BSD, macOS, Haiku, and the rest.

Three behaviors depending on how the flag is passed:

| Invocation | Result |
|---|---|
| (no flag) | default ident: `FPC Unleashed <version> [<date>] for <cpu> - <target>` |
| `--fpcsignature=<str>` | the exact `<str>` is embedded, raw and uninterpreted |
| `--fpcsignature=` (empty) | the `.fpc.version` section is **not emitted at all** - no FPC marker in the binary |

The empty form is the explicit "no signature" switch and is different from omitting the flag.

### Why

The default ident is descriptive metadata that any `strings` pass over the binary can read. The flag exists so you control what (if anything) ends up there - it is your binary. Common cases:

**Keep "FPC", drop the fingerprint.** The default exposes the exact compiler version and build date; `--fpcsignature=FPC` keeps a generic toolchain marker without the detail:

```
fpc --fpcsignature="FPC" myapp.lpr
```

**Brand the binary.** Make `strings myapp` show your build identity, not the toolchain:

```
fpc --fpcsignature="MyApp 1.2.3 (build 4567)" myapp.lpr
```

**No marker at all.** Harden against casual inspection - combined with [striprtti](strip-rtti.md) (which empties the type-name strings in RTTI / VMT), the binary announces neither the compiler nor the Pascal types inside:

```
fpc --fpcsignature="" myapp.lpr
```

## `--linkerversion=<Major.Minor>`

Sets the linker version fields in the PE optional header. `Major.Minor`, decimal, each fitting a byte (0..255); the minor may be omitted (`14` parses as `14.0`).

```
fpc --linkerversion=14.39 demo.pas    # MajorLinkerVersion=14 MinorLinkerVersion=39
fpc --linkerversion=8     demo.pas    # 8.0
```

Default derives from the FPC version (`3.31` for FPC 3.3.1), which uniquely identifies the toolchain - dumpbin, Process Explorer, CFF Explorer, PE-bear, and the Explorer "Details" tab all surface the field directly. Set it to whatever you want the binary to report:

```
fpc --linkerversion=14.39 myapp.lpr   # reads like a current MSVC link.exe
fpc --linkerversion=2.40  myapp.lpr   # reads like GNU ld 2.40
```

Descriptive metadata only - the Windows loader does not consult it.

## `--osversion=<spec>`

Sets the minimum-OS-version fields in the PE optional header. Two input forms:

### Form 1: OS name

A symbolic name resolved through a built-in, **case-insensitive** table that accepts an optional `Win` prefix - `XP`, `xp`, `WinXP`, `winxp` all resolve identically.

| Name | Major | Minor |
|---|---|---|
| `95` | 4 | 0 |
| `98` | 4 | 10 |
| `ME` | 4 | 90 |
| `2000` | 5 | 0 |
| `XP` | 5 | 1 |
| `2003` | 5 | 2 |
| `Vista` | 6 | 0 |
| `7` | 6 | 1 |
| `8` | 6 | 2 |
| `8.1` | 6 | 3 |
| `10` / `11` | 10 | 0 |

`10` and `11` both resolve to `10.0` - the MajorOS value Windows 11 itself reports (Microsoft kept the major at 10 for compatibility).

### Form 2: numeric

Anything not in the table falls through to numeric parsing as `Major[.Minor]`, both decimal words (0..65535):

```
fpc --osversion=10.0 demo.pas    # minimum Windows 10
fpc --osversion=6.3  demo.pas    # minimum Windows 8.1
fpc --osversion=5    demo.pas    # 5.0 (Windows 2000)
```

### Default

Without the flag: the `-WP<X>.<Y>` value if one was passed, otherwise `4.0` (the historical Windows 95 baseline, same as upstream FPC).

### Why

- **Loader gating** - the Windows loader refuses to start an executable whose minimum OS version is higher than the running system. `--osversion=10.0` makes the binary refuse to load on Windows 7 / 8 - useful for forced-upgrade messaging or to keep a build off systems you have not tested.
- **Honest (or arbitrary) metadata** - PE inspectors surface the field (`Required OS: ...`); the `4.0` default has not been meaningful in decades. Set what you actually require - or whatever you want reported.

## Cross-platform note

Only `--fpcsignature` works everywhere. The other two are PE-specific because the fields do not exist elsewhere:

- **ELF** (Linux, BSD, Solaris, Haiku, Android) - `e_version` is the ELF format version, not a linker / OS version; there is no place to write these values.
- **Mach-O** (macOS, iOS) - has `LC_BUILD_VERSION` / `LC_VERSION_MIN_*`, but FPC delegates executable layout to the system `ld`, which fills them from the SDK; the compiler CLI cannot reach those fields.
- **NE** (Win16) - has the fields but hardcodes them (`6.1` linker, Windows 3.0 expected version) for Borland Pascal 7 compatibility.
- **OMF / NLM / WASM / AmigaOS hunk / Atari TOS** - no such fields or a different format entirely.

Passing `--linkerversion=` / `--osversion=` on a non-PE target compiles cleanly; the values are silently ignored.

## Recipes

Branded Windows release - custom signature, MSVC-looking linker version, minimum Windows 11:

```
fpc -Twin64 --fpcsignature="MyApp 2.0" --linkerversion=14.39 --osversion=Win11 my_app.lpr
```

Fully de-badged binary - no toolchain marker, generic linker version, RTTI names stripped except what the LCL needs:

```
fpc -Twin64 -Munleashed --fpcsignature="" --linkerversion=14.39 --rttiexpose=TForm*,TFrame*,TDataModule* my_app.lpr
```

## Demo

Any program works - the flags touch only metadata:

```pascal
program meta_demo;

{$mode unleashed}

begin
  writeln('payload runs the same regardless of metadata');
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Observed on win64 with this exact program:

```
> fpc meta_demo.pp
> strings meta_demo.exe | grep "FPC Unleashed"
FPC Unleashed 3.3.1 [2026/07/28] for x86_64 - Win64

> fpc --fpcsignature="MyApp 1.2.3 (build 4567)" meta_demo.pp
> strings meta_demo.exe | grep -E "MyApp|FPC Unleashed"
MyApp 1.2.3 (build 4567)

> fpc --fpcsignature= meta_demo.pp
> strings meta_demo.exe | grep -E "MyApp|FPC Unleashed"
(nothing - the section is gone)

> fpc --linkerversion=14.39 --osversion=6.3 meta_demo.pp
> (read PE optional header)
linker=14.39 os=6.3
```

## See also

- [Strip RTTI](strip-rtti.md) - the companion mechanism for emptying type-name strings in RTTI / VMT. Combine with `--fpcsignature=""` and a custom `--linkerversion=` for a binary whose external metadata does not advertise the toolchain.
