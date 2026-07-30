# Unleashed Pascal

**Unleashed Pascal** is a community-driven fork of **Free Pascal** for developers who want modern language features today, not after an official release that will likely never ship them. Everything upstream rejected, ignored, or shelved as "too experimental" lives here, and it all turns on with one line:

```pascal
{$mode unleashed}
```

The mode is based on `objfpc`; every modeswitch-gated feature can also be enabled individually in `objfpc` / `delphi` via `{$modeswitch X}`. Backward compatibility is the one hard rule: everything is opt-in, and existing Pascal code keeps compiling untouched. The compiler always defines `UNLEASHED`, so a shared source tree can `{$ifdef}` its way between stock FPC and Unleashed; the mode itself defines `FPC_UNLEASHED` (and not `FPC_OBJFPC`).

> **Already sold, don't care about the tour?** [Yeah yeah, just scroll me straight down to the install steps.](#installation)

## Sixty seconds of Unleashed Pascal

A complete program. Every commented line is a separate feature, and all of them ship today.

```pascal
program taste;

{$mode unleashed}

uses Classes, SysUtils;

// statement expression: if as a value
function fib(n: integer): int64;
begin
  result := if n < 2 then n else fib(n-1)+fib(n-2);
end;

// tuple return type
function minMax(const a: array of integer): (lo, hi: integer);
begin
  result := (a[0], a[0]);
  for var v in a do begin // inline loop variable
    if v < result.lo then result.lo := v;
    if v > result.hi then result.hi := v;
  end;
end;

var hits: integer;

begin
  var nums := [34, 7, 23, 32, 5, 62];              // inferred array of LongInt
  var (lo, hi) := minMax(nums);                    // tuple destructuring
  writeln($'min = {lo}, max = {hi}');              // string interpolation

  var f := async fib(32);                          // background thread, one keyword

  for parallel var i := 1 to 1000 do               // loop body across all cores
    if fib(15) = 610 then lock(hits) do hits += 1; // zero-setup critical section

  writeln($'fib(32) = {await f}, hits = {hits}');

  var log := autofree TStringList.Create;          // freed at scope exit, no finally
  log.Add($'finished at {Now:hh:nn:ss}');
  write(log.Text);
  {$ifdef WINDOWS}readln;{$endif}
end.
```

## What is in the box

Every feature has a full reference page in [unleashed/docs/](unleashed/docs/README.md) - the complete grammar, semantics, edge cases, IDE notes, and a runnable demo for each.

### Concurrency without ceremony

Threads in stock Pascal mean `TThread` subclasses, hand-managed critical sections, and unit-level `threadvar`. Each collapses into a keyword.

| Feature | One-liner | Docs |
|---|---|---|
| **`async` / `await`** | `var f := async work(x); ... writeln(await f);` - one thread per `async`, one join per `await` | [async-await.md](unleashed/docs/async-await.md) |
| **`for parallel`** | `for parallel var i := 1 to N do ...` - loop body across a worker pool, with a barrier | [parallelfor.md](unleashed/docs/parallelfor.md) |
| **`lock` / `trylock`** | `lock(counter) do inc(counter);` - hidden critical section, auto init and release | [lock.md](unleashed/docs/lock.md) |
| **`threadstatic`** | `threadstatic next := 1000;` - a per-thread variable, init once per thread | [thread-static.md](unleashed/docs/thread-static.md) |

### Write less, say more

| Feature | One-liner | Docs |
|---|---|---|
| **Inline Variables** | `var x := 42;` at the point of use, with type inference and block scope | [inline-vars.md](unleashed/docs/inline-vars.md) |
| **Statement Expressions** | `var s := if x > 0 then 'pos' else 'neg';` - `if` / `case` / `try` yield values | [statement-expressions.md](unleashed/docs/statement-expressions.md) |
| **`match`** | `match cmd of 'go': run; _: skip; end;` - first-match dispatch over strings, tuples, conditions | [match.md](unleashed/docs/match.md) |
| **Tuples** | `function pair: (integer, integer);` then `var (a, b) := pair;` | [tuples.md](unleashed/docs/tuples.md) |
| **String Interpolation** | `writeln($'Hello {name}, pi = {pi:%.2f}');` | [string-interpolation.md](unleashed/docs/string-interpolation.md) |
| **`for ... step`** | `for var i := 1 to 10 step 2 do ...` | [forstep.md](unleashed/docs/forstep.md) |
| **Multi-Var Init** | `var a, b, c: integer = 42;` - one initializer, independent copies | [multi-var-init.md](unleashed/docs/multi-var-init.md) |
| **`SwapValues()`** | `SwapValues(a, b);` - bitwise swap, no `uses`, no refcount churn | [swapvalues.md](unleashed/docs/swapvalues.md) |
| **`Type()`** | `var tmp: Type(a[0]);` - static type of an expression, operand unevaluated | [type-intrinsic.md](unleashed/docs/type-intrinsic.md) |
| **128-bit Integers** | `var x: UInt128 := 340282366920938463463374607431768211455;` | [int128.md](unleashed/docs/int128.md) |

### Records and memory layout

| Feature | One-liner | Docs |
|---|---|---|
| **Composable Records** | `embed TBase;`, `union ... end;`, `bitpacked record of byte`, `OffsetOf(T.field)` - C-struct layout, Pascal safety | [composable-records.md](unleashed/docs/composable-records.md) |
| **Flexible Array Members** | `data: array[] of byte;` as the last field - C99-style variable tail | [flexible-arrays.md](unleashed/docs/flexible-arrays.md) |
| **Static Variables** | `static cnt: integer = 0;` - program lifetime, block scope | [static-section.md](unleashed/docs/static-section.md) |
| **Scoped Cleanup** | `defer x.Free;`, `var x := autofree T.Create;`, `with var http := autofree ...` | [autofree.md](unleashed/docs/autofree.md) |
| **`zeroinit`** | `procedure foo; zeroinit;` - zero every local at entry | [zeroinit.md](unleashed/docs/zeroinit.md) |
| **Aligned Heap** | `GetMemAligned(size, 64)` and friends in `system` | [introduced-functions.md](unleashed/docs/introduced-functions.md) |

### Classes and generics

| Feature | One-liner | Docs |
|---|---|---|
| **Auto-Properties** | `property Name: string;` synthesizes a backing field - zero overhead | [auto-properties.md](unleashed/docs/auto-properties.md) |
| **Nested Generic Methods** | `function pair<U>(...)` inside `TBox<T>` - class and method specialize independently | [extra-improvements.md](unleashed/docs/extra-improvements.md) |
| **Implicit Generics + Type Helpers** | `TList<integer>` without `generic` / `specialize`; `type helper for integer`; multiple helpers at once | [extra-improvements.md](unleashed/docs/extra-improvements.md) |

### Your binary, your rules

| Feature | One-liner | Docs |
|---|---|---|
| **Strip RTTI** | `{$modeswitch striprtti}` empties type-name strings; `expose` / `--rttiexpose=` whitelist | [strip-rtti.md](unleashed/docs/strip-rtti.md) |
| **Custom Binary Metadata** | `fpc --fpcsignature="" --linkerversion=14.39 --osversion=Win11` | [binary-metadata.md](unleashed/docs/binary-metadata.md) |
| **File Embedding** | `{$embedbytes preset 'default.bin'}` bakes a file into the binary | [embed.md](unleashed/docs/embed.md) |

### Strings and literals

| Feature | One-liner | Docs |
|---|---|---|
| **Multiline Strings** | backtick `` `...` `` (byte-exact) and triple-quote `'''...'''` (auto-trimmed) | [multiline-strings.md](unleashed/docs/multiline-strings.md) |
| **Numeric Underscores** | `1_000_000`, `$FFFFFFFF_FFFFFFFF` | [extra-improvements.md](unleashed/docs/extra-improvements.md#numeric-underscores) |
| **String-to-Ordinal Cast** | `dword('RIFF')` folds to a constant in native endianness | [extra-improvements.md](unleashed/docs/extra-improvements.md) |

### Quality-of-life tweaks

Semantic adjustments and small syntax unlocks - full catalog in [tweaks.md](unleashed/docs/tweaks.md) and [extra-improvements.md](unleashed/docs/extra-improvements.md).

- **Preserved For-Loop Counter** - after `for i := 1 to N do ... break;` the counter keeps its value.
- **`is not` / `not in`** - `if obj is not TFoo then`, `if x not in [a, b] then`.
- **Compound Assignment** - `i div= 2;`, `flags xor= $05;` in every mode; `+=` and friends without `{$coperators on}`; both work on properties, as do `inc()` / `dec()`.
- **Array Size Shorthand** - `array[10] of T` means `array[0..9] of T`.
- **Array Equality** - `if a = b then` compares two arrays element by element.
- **Indexed and Lazy Labels** - `label state[0..4]; goto state[n];` compiles to a case dispatch; `goto done;` needs no prior declaration.
- **`goto`, Macros, C-Operators without Directives** - all implied by the mode.
- **`DEBUG` / `RELEASE` Defines** - set automatically from `-g`: react to a debug build with `{$ifdef DEBUG}`, no `-dDEBUG` needed.

## Detailed documentation

Each feature has a dedicated reference page with the full grammar, semantics, edge cases, IDE notes, and a runnable demo. Start at the index: [unleashed/docs/README.md](unleashed/docs/README.md).

## Installation

### Option 1: Official installer (recommended)

Self-contained GUI installer for Windows and Linux: it downloads sources, builds the compiler and the Lazarus IDE into a directory of your choice, optionally installs cross compilers, and drops a desktop shortcut. No PATH changes, no registry side effects, no overwriting of an existing FPC. Run it again any time to add a cross target or pull an update - it applies only that change and leaves the rest of the install alone.

- Repo: [fpc-unleashed/installer](https://github.com/fpc-unleashed/installer)
- Downloads: [installer/releases](https://github.com/fpc-unleashed/installer/releases) - tagged stable releases plus a rolling `nightly` that tracks `main`
  - `installer_win64_x86_64.exe` - Windows host
  - `installer_linux_x86_64` / `installer_linux_x86_64.AppImage` - Linux host

Run it, pick a directory (default `C:\unleashed` on Windows, `$HOME/unleashed` on Linux), tick the cross targets you want, click Install.

### Option 2: Fresh install via fpcupdeluxe

1. Download [fpcupdeluxe](https://github.com/LongDirtyAnimAlf/fpcupdeluxe) and run it once to generate `fpcup.ini`.
2. Add to `fpcup.ini`:

```ini
[ALIASfpcURL]
unleashed.git=https://github.com/fpc-unleashed/freepascal.git

[ALIASlazURL]
unleashed.git=https://github.com/fpc-unleashed/lazarus.git
```

3. Reopen **fpcupdeluxe**, uncheck **GitLab**, and select `unleashed.git` as both the **FPC version** and the **Lazarus version**.
4. In **Setup+** tick **Docked Lazarus IDE** (required - the default window layout is tuned for docked mode).
5. Click **Install/update FPC+Lazarus**. Cross-compilers are on the `Cross` tab.

![fpcupdeluxe](unleashed/img/installation_fpcupdeluxe.png)

### Option 3: Upgrade an existing fpcupdeluxe setup

Delete or rename the `fpcsrc` folder in your installation directory, then:

```bash
git clone https://github.com/fpc-unleashed/freepascal.git fpcsrc
```

In fpcupdeluxe: **Setup+**, check **FPC/Laz rebuild only**, confirm, then click **Only FPC**.

## Unleashed IDE

For the best experience, use **[Lazarus Unleashed](https://github.com/fpc-unleashed/lazarus)** - a fork of the Lazarus IDE that understands unleashed mode end to end. Its parser, code completion, and Code Insight know the new syntax, so inline vars, tuples, `match`, `async` / `await`, and the rest autocomplete and navigate like any built-in construct, with no false-positive error markers in the editor.

Stock Lazarus still builds and runs Unleashed projects fine, but its Code Insight does not recognize the new syntax and will flag it as errors. If you stay on stock Lazarus, enable the mode through `-Munleashed` in the project's Custom Options rather than `{$mode unleashed}` in the source - that keeps the editor's background parser quieter about the constructs it cannot model.

## Contributing

**Unleashed Pascal** is a home for innovation. If you have built a language feature that was considered _too experimental_ or _not standard enough_ for upstream, this is where it belongs.

We are looking for **new language ideas** - propose modeswitches, syntax extensions, or compiler enhancements via GitHub Issues or Discussions; a well-described idea with clear use cases is valuable even without an implementation - and **complete, high-quality implementations** with production-grade code, test coverage, and documentation.

We are not looking for minor convenience patches, trivial reformats, or tweaks that only scratch a personal itch. Every change to a compiler carries weight; contributed code should be a meaningful feature or fix that benefits the broader community.
