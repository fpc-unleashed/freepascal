# Custom Binary Metadata

Three CLI flags that override metadata fields the compiler embeds into the produced binary. All three default to "leave the upstream FPC value" when not set.

| Flag | Field | Scope | Default |
|---|---|---|---|
| `--fpcsignature=<str>` | `.fpc.version` ident string | every target | `FPC Unleashed <version> [<date>] for <cpu> - <target>` |
| `--linkerversion=<Major.Minor>` | PE optional header `MajorLinkerVersion` / `MinorLinkerVersion` | Windows PE only | derived from FPC version, e.g. `3.31` for FPC 3.3.1 |
| `--osversion=<spec>` | PE optional header `MajorOperatingSystemVersion` / `MinorOperatingSystemVersion` | Windows PE only | `4.0` unless `-WP<X>.<Y>` is set |

These are CLI-only; there is no directive form. The reason is that they are build-level configuration (think "what should this particular binary look like"), not source-level semantics.

## `--fpcsignature=<str>`

Replaces the ident string in the `.fpc.version` section of the produced object. The section is emitted by the compiler frontend (`InsertMemorySizes` in ngenutil) for every target, so this flag works on Windows, Linux, BSD, macOS, Haiku, etc.

```
fpc --fpcsignature="MyApp 1.2.3 (build 4567)" demo.pas
```

```
$ strings demo
...
MyApp 1.2.3 (build 4567)        <-- replaced ident
hello
...
```

### What `--fpcsignature=` does

Three behaviours depending on whether and how the flag is passed:

| Invocation | Result |
|---|---|
| (no flag at all) | Default ident emitted: `FPC Unleashed <version> [<date>] for <cpu> - <target>`, e.g. `FPC Unleashed 3.3.1 [2026/05/06] for x86_64 - Win64`. |
| `--fpcsignature=<str>` | The exact `<str>` is emitted. |
| `--fpcsignature=` (empty) | The `.fpc.version` section is **not emitted at all** - the produced binary carries no FPC ident marker. |

The empty form is the explicit "no signature" switch and is different from omitting the flag. The string (when present) is embedded as raw bytes; the compiler does not interpret it.

### Why

The default ident string is descriptive metadata that any inspection of the binary can read. The flag exists so that you control what (if anything) ends up there. It is your binary, you decide what it tells the world.

Common cases:

**1. Drop version and date but keep "FPC".** The default exposes the exact compiler version and build date, which may be more than you want to disclose for a release. Setting just `--fpcsignature=FPC` keeps a generic toolchain marker without the build-fingerprint detail:

```
fpc --fpcsignature="FPC" myapp.lpr
# strings myapp:  FPC
```

**2. Brand the binary with your own product identity.** Replace the FPC marker with your application's signature - useful if you want a quick `strings myapp` to show your build identity, not the toolchain:

```
fpc --fpcsignature="MyApp 1.2.3 (build 4567)" myapp.lpr
# strings myapp:  MyApp 1.2.3 (build 4567)
```

**3. No marker at all.** Hide the toolchain entirely - the `.fpc.version` section is dropped from the binary, so neither `FPC`, the version, nor the date are present:

```
fpc --fpcsignature="" myapp.lpr
# strings myapp:  (no FPC-related ident anywhere)
```

This is useful when you want to harden a binary against casual reverse engineering. Combined with `striprtti` (which nulls the type-name strings emitted into RTTI/VMT), the produced binary no longer announces what compiler built it nor which Pascal types it contains. See [Strip RTTI](strip-rtti.md) for the companion mechanism.

The flag does not change generated code - it only controls what string lands in (or is omitted from) the `.fpc.version` section. Behaviour at runtime is identical regardless.

## `--linkerversion=<Major.Minor>`

Sets the linker version fields in the PE optional header. Format is `Major.Minor`, both as decimal integers, fitting in a byte each (so 0..255). Either field may be omitted (`14` is parsed as `14.0`).

```
fpc --linkerversion=14.39 demo.pas    -- Win64 -> MajorLinkerVersion=14 MinorLinkerVersion=39
fpc --linkerversion=2.31  demo.pas    -- 2.31
fpc --linkerversion=8     demo.pas    -- 8.0
```

Default is derived from the FPC version: `MajorLinkerVersion = ord(version_nr) - ord('0')`, `MinorLinkerVersion = ord(release_nr)*10 + ord(patch_nr)`. For FPC 3.3.1 that produces `3.31`.

### Why

PE inspectors and properties dialogs surface the linker version prominently - dumpbin, Process Explorer, CFF Explorer, PE-bear, and the Windows Explorer "Details" tab all read this field directly. By default a binary produced by FPC 3.3.1 reports linker version `3.31`, which uniquely identifies the toolchain.

You may not want to disclose that. Examples:

```
fpc --linkerversion=14.39 myapp.lpr   # looks like current MSVC link.exe
fpc --linkerversion=2.40  myapp.lpr   # looks like GNU ld 2.40
fpc --linkerversion=8.0   myapp.lpr   # looks like an older Microsoft linker
```

This is your binary, set the field to whatever you want. The flag is descriptive metadata - the Windows loader does not consult it, only inspection tools and properties dialogs do. Generated code is unchanged.

Same companion idea as for `--fpcsignature`: paired with `striprtti` and a custom signature, the result is a binary whose external metadata does not advertise FPC. See [Strip RTTI](strip-rtti.md).

### Windows PE only

This field exists only in the PE/COFF optional header (`win32`, `win64`, `wince`). On other targets the flag is silently ignored. See [Cross-platform note](#cross-platform-note) below.

## `--osversion=<spec>`

Sets the minimum-OS-version fields in the PE optional header. Accepts two input forms:

### Form 1: OS name

A symbolic name resolved through a built-in table. The table is **case-insensitive** and accepts an optional `Win` prefix - so `XP`, `xp`, `WinXP`, and `winxp` all resolve identically.

| Name (any case, with or without `Win` prefix) | Major | Minor |
|---|---|---|
| `95`             | 4  | 0  |
| `98`             | 4  | 10 |
| `ME`             | 4  | 90 |
| `2000`           | 5  | 0  |
| `XP`             | 5  | 1  |
| `2003`           | 5  | 2  |
| `Vista`          | 6  | 0  |
| `7`              | 6  | 1  |
| `8`              | 6  | 2  |
| `8.1`            | 6  | 3  |
| `10` / `11`      | 10 | 0  |

`10` and `11` both resolve to `10.0` - that is the actual MajorOS value Windows 11 reports in its PE header (Microsoft kept the major at 10 for backwards-compatibility reasons).

### Form 2: numeric

If the input does not match the table, it falls through to numeric parsing as `Major[.Minor]`. Both fields are decimal integers fitting in a word (0..65535).

```
fpc --osversion=10.0   -- minimum target Windows 10
fpc --osversion=6.3    -- minimum target Windows 8.1
fpc --osversion=5      -- minimum target Windows 2000 (.0 implied)
```

### Default

If `--osversion=` is not set, the compiler falls back to:

1. The value from `-WP<X>.<Y>` if it was passed (`SetPEOSVersionSetExplicitely`).
2. Otherwise `4.0` (Windows 95 baseline - same as upstream FPC).

### Why

Two reasons:

- **Loader gating** - the Windows loader refuses to launch an executable whose `MajorOS` is higher than the running OS version. Setting `--osversion=10.0` makes the binary refuse to load on Windows 7 / 8, which is useful for forced-upgrade messaging or to prevent users from running a build on an OS you have not tested it against.

- **Set the field to whatever you want.** PE inspectors surface the minimum OS version (`Required OS: Windows 10`, `Min OS: 6.3`, ...). The default of `4.0` is a Windows 95 baseline that has not been meaningful for over two decades. Set it to match what you actually require:

  ```
  fpc --osversion=Win10  myapp.lpr   # Required OS: Windows 10
  fpc --osversion=Win11  myapp.lpr   # Required OS: Windows 10  (Win11 reports as 10.0)
  fpc --osversion=6.3    myapp.lpr   # Required OS: Windows 8.1
  fpc --osversion=XP     myapp.lpr   # Required OS: Windows XP
  ```

  Or to whatever you want it to show, including "wrong" values - it is your binary. As with `--linkerversion`, this is descriptive metadata; generated code is unchanged. Combined with `--fpcsignature` and `striprtti`, the produced binary's external profile no longer matches a default FPC build.

### Windows PE only

Same constraint as `--linkerversion`. See below.

## Cross-platform note

Only `--fpcsignature` works on every target. The other two are PE-specific because **the corresponding fields do not exist in non-PE formats**:

- **ELF** (Linux, BSD, Solaris, Haiku, Android) - the ELF header has `e_version`, but it is the ELF format version (always `EV_CURRENT=1`), not a linker or OS version. There is no place in ELF to write what `--linkerversion` or `--osversion` set.
- **Mach-O** (macOS, iOS) - has `LC_BUILD_VERSION` (with a tools entry that records the linker version) and `LC_VERSION_MIN_MACOSX` / `LC_VERSION_MIN_IPHONEOS` (minimum OS). FPC does **not** write these load commands itself - it produces relocatable object files and delegates the executable layout to the system `ld`, which fills these from the SDK. So `--linkerversion` and `--osversion` from FPC's CLI cannot reach those fields.
- **NE** (Win16 i8086 target) - has both fields, but the values are hardcoded (`6.1` for linker, `Win 3.0` for expected Windows version) for Borland Pascal 7 compatibility. Targeting Win16 is a niche use case.
- **OMF** (DOS 32-bit), **NLM** (Novell), **WASM**, **AmigaOS hunk**, **Atari TOS** - either no such field or a different format entirely.

Passing `--linkerversion=` or `--osversion=` on a non-PE target compiles cleanly but the value is silently ignored.

## Examples

Branded release with a custom signature, modern linker version, minimum Windows 11:

```
fpc -Twin64 \
    --fpcsignature="MyApp 2.0 - released 2026-05" \
    --linkerversion=14.39 \
    --osversion=Win11 \
    my_app.lpr
```

Linux release - only signature has any effect on this target:

```
fpc -Tlinux \
    --fpcsignature="MyApp 2.0 - released 2026-05" \
    my_app.lpr
```

Strip the FPC marker entirely, keep the linker version generic (looks like a current MSVC linker), whitelist only the type names that LCL actually needs at runtime:

```
fpc -Twin64 \
    -Munleashed \
    --fpcsignature="" \
    --linkerversion=14.39 \
    --rttiexpose=TForm*,TFrame*,TDataModule* \
    my_app.lpr
```

Keep "FPC" but drop the version and date (good middle ground - the binary still identifies as a Free Pascal product, just not which one):

```
fpc --fpcsignature="FPC" my_app.lpr
```

## See also

- [Strip RTTI](strip-rtti.md) - the companion mechanism for nulling type-name strings emitted into RTTI/VMT. Combine with `--fpcsignature=""` and a custom `--linkerversion=` to produce a binary whose external metadata does not advertise the toolchain.
