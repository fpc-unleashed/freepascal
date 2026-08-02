# Unleashed Pascal - Documentation

This is the index and introduction to the detailed feature reference. Every feature Unleashed Pascal adds on top of stock Free Pascal is listed below, grouped by theme, each with a short description and a link to its full page (grammar, semantics, every edge case, and a runnable demo).

## The mode and its switches

One line enables everything:

```pascal
{$mode unleashed}
```

`{$mode unleashed}` is based on `objfpc`. Every modeswitch-gated feature can also be enabled individually from `objfpc` / `delphi` with `{$modeswitch X}`, and switched back off inside an unleashed unit with `{$modeswitch X-}`. The one hard rule is backward compatibility: new constructs are recognized only when their switch is active, so existing Pascal keeps compiling unchanged.

### Modeswitches on by default in `{$mode unleashed}`

| Modeswitch | Feature |
|---|---|
| `inlinevars` | inline variable declarations with type inference |
| `staticsection` / `inlinestatic` | `static` variables (section and inline forms) |
| `threadstatic` | per-thread `threadstatic` / `tstatic` variables |
| `statementexpressions` | `if` / `case` / `try` as expressions |
| `tuples` | anonymous tuple types, literals, destructuring |
| `match` | first-match pattern matching |
| `multivarinit` | one initializer for several variables |
| `outvar` | inline out-variable `f(var x)` and discard `f(_)` |
| `forstep` | `step N` clause in `for` loops |
| `autoproperties` | accessor-less properties with a synthesized backing field |
| `parallelfor` | `for parallel` worker-pool loops |
| `asyncawait` | `async` / `await` thread futures |
| `lock` | `lock` / `trylock` thread-safe blocks |
| `autofree` | `defer`, `autofree`, scoped `with` |
| `flexiblearrays` | C99-style flexible array members |
| `composablerecords` | `embed`, `union`, bitfields, layout intrinsics |
| `interpolatedstrings` | `$'Hello {name}'` placeholders |
| `multilinestrings` | backtick and triple-quote literals |
| `stringordcast` | `dword('RIFF')` constant fold |
| `arrayequality` | `=` / `<>` between arrays (needs `arrayoperators`, also on) |
| `underscoreisseparator` | `1_000_000` numeric literals |
| `int128` | 128-bit integer literals (the types are always available) |
| `implicitgenerics` | Delphi-style `<T>` without `generic` / `specialize` |
| `typehelpers` / `multihelpers` | helpers on any type, several at once |

Also switched on by `{$mode unleashed}` on top of the `objfpc` base - supporting modern-Pascal switches rather than headline features: `ansistrings`, `advancedrecords`, `arrayoperators`, `anonymousfunctions`, `functionreferences`, `duplicatelocals`.

**Off by default**, opt-in only: `striprtti`.

Also turned on automatically with no directive needed: C-style operators (`+=`, `-=`, `*=`, `/=`), `goto` / `label`, and macros (`{$define name := value}`). Each can be switched off locally.

Several features are **unleashed-mode-only with no dedicated modeswitch**: the preserved for-loop counter, `is not` / `not in`, compound assignment and `inc()` / `dec()` on properties, array size shorthand, lazy labels, nested generic methods, `zeroinit`, forced `inline`, `SwapValues()`, and `Type()`. A few work in **every mode** with no switch at all: the word-based compound operators (`div=`, `mod=`, ...), indexed labels, `$embedstr` / `$embedbytes`, and the custom-binary-metadata CLI flags.

### Conditional Defines

The compiler always defines `UNLEASHED`, in every mode and on every target. It identifies the Unleashed compiler, not the active mode, so one source tree stays compatible with stock FPC:

```pascal
{$ifdef UNLEASHED}
  {$mode unleashed}
{$else}
  {$mode objfpc}
{$endif}
```

`{$mode unleashed}` has its own mode marker, `FPC_UNLEASHED`, following the `FPC_*` naming convention of `FPC_OBJFPC` and `FPC_DELPHI`; the CLI form `-Munleashed` sets it the same way. The mode markers are mutually exclusive: even though the mode is based on `objfpc`, switching to it does not define `FPC_OBJFPC`. Code that wants "objfpc or any superset of it" checks `{$if defined(FPC_OBJFPC) or defined(FPC_UNLEASHED)}`.

The build kind is exposed as a define too: `DEBUG` when the compiler options enable debug info (`-g` and friends on the command line or in `fpc.cfg`, or "Generate info for the debugger" checked in the IDE's Project Options), `RELEASE` otherwise. Source can react to a debug build without a separate `-dDEBUG`:

```pascal
{$ifdef DEBUG}
writeln('debug build with call traces');
{$endif}
```

An explicit `-dDEBUG` / `-dRELEASE` keeps working as before; the automatic define just makes it unnecessary in the common case.

---

## Concurrency

### [`async` / `await` - Thread Futures](async-await.md)

`async <call>` or `async begin..end` runs work on a fresh worker thread and returns a `future of T` (or a bare `future`); `await f` joins that thread and reads the result. This is the `std::async` model - one thread per `async`, one join per `await`, no function coloring and no event loop. The call form snapshots the call's arguments by value at the spawn point; the block form captures referenced locals by reference, so the future may outlive its spawner. Awaiting is repeatable and cached, a worker exception re-raises on the caller at the first `await`, and the future carries a control surface (`Cancel()`, `Cancelled`, `Done`, `ThreadID`). A companion `sync begin..end` marshals a block onto the main thread for GUI work. Built on `system`-unit thread primitives; on Unix the program needs `cthreads` first in `uses`. Modeswitch `asyncawait`.

### [`for parallel`](parallelfor.md)

`for parallel [(N)] var i := lo to|downto hi [step s] [chunk c] do STMT` runs the loop body across a `BeginThread()` worker pool. Every iteration runs once, the loop is a barrier (control passes `do` only after all iterations finish), iteration order is undefined, and shared writes need atomics or a lock. The counter must be inline `var` so each worker owns its copy. Optional pool size, `downto`, `step`, and `chunk` compose; `WorkerIndex` / `WorkerCount` give lock-free per-worker slots; `break` cancels cooperatively; the first worker exception re-raises after the barrier. Modeswitch `parallelfor`.

### [`lock` / `trylock`](lock.md)

`lock ... do <stmt>` and `trylock ... do <stmt> else <stmt>` serialize access across threads on top of a hidden `TRTLCriticalSection`, with automatic init / done and guaranteed release. `lock` blocks until acquired and cannot fail; `trylock` may miss (one attempt, or a bounded `wait N` milliseconds) and runs the mandatory `else` without the lock. Targets are a hidden per-callsite lock (bare form), a hidden per-variable lock shared program-wide (`lock(v)`), or an explicit user-managed `TRTLCriticalSection`. Multi-target sites take locks in a canonical order so `lock(a, b)` vs `lock(b, a)` cannot deadlock. The wait machinery uses only `system`-unit primitives. Modeswitch `lock`.

### [`threadstatic` Variables](thread-static.md)

`threadstatic` (alias `tstatic`) declares a per-thread variable with program lifetime and block-local scope - a per-thread cache or counter without a unit-level `threadvar`. Each thread gets its own copy via FPC's TLS infrastructure; the initializer runs once per thread on first reach, behind a per-thread guard. Two forms with identical semantics: an inline statement and a declaration section before the body. A zero-valued constant initializer drops the guard; every other value needs the guarded runtime assignment (TLS has no per-thread template). Modeswitch `threadstatic`.

---

## Write less, say more

### [Inline Variables](inline-vars.md)

Declare variables at the point of first use, with type inference (`var x := expr`), block scoping in nested `begin..end`, and use in `for` headers and `with var` clauses. Inline `const` works the same way. This is the default way to declare locals in Unleashed Pascal. Block-scoped inline vars emit proper DWARF lexical blocks, so the debugger shows only what is in scope at the current line. The hard rule: inline `var` requires `:=`, classic `var` / typed `const` require `=`. Modeswitch `inlinevars`.

### [Out-Variables](out-var.md)

`f(var x)` at an `out`-argument position declares a fresh variable typed from the parameter and scoped to the enclosing block; `f(_)` discards the output. No more pre-declaring a throwaway local for every `Try*` routine. Accepted only at an `out` parameter, resolved after overload selection, and a declared identifier `_` always wins over the discard meaning, so existing code is unaffected. Modeswitch `outvar`.

### [Statement Expressions](statement-expressions.md)

`if`, `case`, and `try` as expressions that yield a value, computed where it is consumed. Only the taken branch is evaluated, numeric branches widen to a common type, and `try X except 'fallback'` turns an exception into a value. Each branch is a single expression - value-less statements (`raise`, `exit`) are rejected. Modeswitch `statementexpressions`.

### [`match` Statement](match.md)

First-match pattern matching - a superset of `case`. It adds string subjects, a catch-all (`_` / `else` / `otherwise`), comma patterns, ranges, subject-less condition branches, tuple patterns with `_` wildcards, a fallthrough mode (`match all` + `leave`), and an expression form. The modern default for value dispatch; reach for `case` only for a plain ordinal switch. Modeswitch `match`.

### [Anonymous Tuples](tuples.md)

Lightweight anonymous record types written in parentheses - `(integer, string)` or `(x, y: integer)` - with literals, destructuring, comparison, `for-in` unpacking, arrays of tuples, and `exit(a, b)` sugar. They replace out-parameter pairs and one-shot record types declared only to return two values. Built on the existing record infrastructure, so managed types, copy semantics, and calling conventions come for free. Modeswitch `tuples`.

### [String Interpolation](string-interpolation.md)

`$'...'` literals with `{expr}` and `{expr:mask}` placeholders, type-checked and concatenated at compile time - no `+` chains, no `IntToStr()`, no hand-rolled `Format()`. Bare placeholders auto-format by type; masks dispatch to `Format()` / `FormatDateTime()` / `FormatFloat()` / `IntToHex()` by shape and type (those need `uses SysUtils`), and a plain-width mask needs nothing. The default locale is invariant; an `L` prefix opts into the system locale. Modeswitch `interpolatedstrings`.

### [`for ... step`](forstep.md)

`step N` in a `for` header advances the counter by an arbitrary positive amount, composing with `to` / `downto`, inline `var`, and `for parallel`. The step is evaluated once before the loop; a constant `step 1` folds back to a regular for-loop. `step` is context-sensitive, so existing code using it as an identifier keeps compiling. Modeswitch `forstep`.

### [Multi-Variable Initialization](multi-var-init.md)

Initialize several variables of the same type with one value: `var a, b, c: integer = 42;`. Works in `var` sections, typed constants, and inline `var`, and each name gets an independent copy. For inline vars the initializer is evaluated once and copied to each name. Modeswitch `multivarinit`.

### [128-bit Integers](int128.md)

Native `Int128` and `UInt128` that behave like any other ordinal - arithmetic, `div` / `mod`, shifts, bitwise, comparisons, `inc()` / `dec()` / `succ()` / `pred()`, `for`, `case`, range / overflow checks, `Str()` / `Val()`, and `Write` / `Read` all work. Reach for these instead of a bignum library whenever the values fit 128 bits. The types are always available on every target; only integer literals wider than 64 bits need the switch. On the 64-bit register targets the common operations are inline register-pair code. Modeswitch `int128`.

### [`SwapValues()` Intrinsic](swapvalues.md)

`SwapValues(a, b)` swaps two same-typed assignable variables with a bitwise move, callable with no `uses` beyond the implicit `System` unit. For managed types it swaps the reference words with zero refcount churn; property operands swap through a hidden temporary that drives the accessors. A user-declared `SwapValues()` shadows the builtin, so it never breaks existing code. Unleashed-mode only, no modeswitch.

### [`Type()` Intrinsic](type-intrinsic.md)

`Type(expr)` yields the static type of an expression without evaluating it - Pascal's counterpart to `decltype`. Valid in every type-bearing position (declarations, casts, `SizeOf()` / `Default()` arguments, derived types like `array of Type(x)`). The operand is type-checked but never reaches code generation, so `Type(a[0])` is safe on an empty array and `Type(f())` does not call `f`. Unleashed-mode only, no modeswitch.

---

## Records and memory layout

### [Composable Records](composable-records.md)

C-struct-grade layout control with Pascal type safety. `embed T;` flattens another record's fields, methods, properties, and operators into the outer one; an anonymous `record ... end;` body flattens inline; `union ... end;` overlaps memory without a discriminator and can appear anywhere in the body. Add per-record and per-field `align` / `size` / `bitsize` modifiers, `bitpacked record of Byte` C-style bitfields with `pad N;`, record-scoped anonymous enums with storage anchors (`kind: (kA, kB) of Byte;`), and compile-time `OffsetOf()` / `BitOffsetOf()` / `AlignOf()` / `BitAlignOf()` / `BitSizeOf()` intrinsics. The tool for porting WinAPI / POSIX headers 1:1. Modeswitch `composablerecords`.

### [Flexible Array Members](flexible-arrays.md)

A C99-style variable-length tail: `data: array[] of T` as the last record field. The header has the size `sizeof()` reports; the tail extends as far as the allocation says, and indexing skips range checks because there is no upper bound. One `GetMem(rec, sizeof(rec)+payload)` covers header and tail together - the honest replacement for the `array[0..0]` / `ANYSIZE_ARRAY` hack. An optional `count` clause (or automatic detection of the preceding count field) drives debugger pretty-printing. Modeswitch `flexiblearrays`.

### [Static Variables](static-section.md)

A writable `static` storage class with program-wide lifetime and block-local scope - C's `static int x;` inside a function. A section form takes compile-time initializers and lands in the data segment at zero runtime cost; an inline form takes runtime initializers behind a once-only guard (set before evaluation, so a raised initializer leaves the variable zeroed and is not retried). Modeswitches `staticsection` and `inlinestatic`.

### [Scoped Cleanup - `defer`, `autofree`, scoped `with`](autofree.md)

`defer STATEMENT;` registers an action to fire at scope exit in LIFO order (on normal exit, `exit`, `break`, `continue`, and exception; argument expressions evaluated at exit). `autofree EXPR` turns a fresh class instance into a scoped resource with a nil-guarded `Free()`. The `with` statement gains inline-var bindings (`with var x := autofree T.Create do ...`) so the holder is named, scoped, and cleaned up in one line. The default replacement for `try..finally` boilerplate. Modeswitch `autofree`.

### [`zeroinit` Procedure Modifier](zeroinit.md)

`procedure foo; zeroinit;` zero-initializes every local (including `result`) at entry, in declaration order, before any user statement. New locals are covered automatically, and reads of locals no longer raise the uninitialized-variable warning. Deterministic stack frames for defensive code, codegen targets, and FFI shims. File-type locals keep their RTL init; mutually exclusive with `external` / `interrupt` / `assembler`. Unleashed-mode only, no modeswitch.

### [Forced Inlining](forced-inline.md)

In `{$mode unleashed}` `inline` means inline: every direct call expands, with no size heuristics, at every optimization level, and independent of definition order (a caller parsed before the body waits for it - `forward` combines with `inline` too). When a call cannot be expanded (recursion, nested routines, mutual recursion, a framed assembler body), a warning names the reason and a regular call is emitted. `{$inline off}` degrades the routines declared under it back to stock hints, so a debug build can drop the expansions without touching the sources. Bodies with embedded `asm` statements expand, and a pure `nostackframe` `assembler` body is spliced at the call site. Taking `@Routine` stays legal - indirect calls are ordinary calls. Unleashed-mode only, no modeswitch.

### [Introduced Functions, Procedures and Intrinsics](introduced-functions.md)

A reference table of identifiers Unleashed adds that user code can call without an extra `uses`: the composable-records layout intrinsics (`OffsetOf()`, `BitOffsetOf()`, `AlignOf()`, `BitAlignOf()`, extended `BitSizeOf()`), and the aligned heap allocator in the `system` unit (`GetMemAligned()`, `AllocMemAligned()`, `ReAllocMemAligned()`, `FreeMemAligned()`) - the runtime half of `record align 64` cache-line layouts.

---

## Classes and generics

### [Auto-Properties](auto-properties.md)

A property with a type but no `read` / `write` synthesizes a `strict private` backing field and binds straight to it - identical code to a hand-written field-backed property, zero overhead. A `= constexpr` seeds the field at construction (before the constructor body); `readonly` / `writeonly` narrow the direction; `class property` gets a `class var` field; records work too; and published auto-properties are RTTI-complete. Modeswitch `autoproperties`.

### [Extra Improvements](extra-improvements.md)

Smaller unlocks that stock modes reject, gathered on one page: **string-to-ordinal cast** (`dword('RIFF')` folds to a native-endian constant, modeswitch `stringordcast`), **type helpers on any named type** and **multi-helpers** (`typehelpers` / `multihelpers`), **implicit generics** (Delphi-style `<T>` without `generic` / `specialize` - the switch replaces the explicit keywords rather than stacking on them, modeswitch `implicitgenerics`), **nested generic methods** (a generic method with its own type parameter inside a generic class, unleashed-only), and the **`array[N]` size shorthand** (`array[10] of T` = `array[0..9] of T`, unleashed-only). Compound assignment and `inc()` / `dec()` on properties have moved to their own page below.

---

## Your binary, your rules

### [Strip RTTI](strip-rtti.md)

`{$modeswitch striprtti}` (opt-in, per unit) empties the type-name strings in RTTI / VMT structures, so an ASCII dump of the binary no longer reveals internal type names. Three whitelisting mechanisms cover code you do and do not control: the `expose` keyword per declaration, `{$rttiexpose TForm*}` per unit, and `--rttiexpose=TForm*` globally on the command line. Anything that walks RTTI by string (`Application.CreateForm`, `MethodAddress()`, `GetPropInfo()`, `WriteStr()` on enums) needs its types whitelisted. Off by default in unleashed mode.

### [Custom Binary Metadata](binary-metadata.md)

Three CLI flags that override metadata the compiler embeds into the binary: `--fpcsignature=` (the `.fpc.version` ident string on every target; an empty value drops the section entirely), `--linkerversion=` and `--osversion=` (PE optional header fields on Windows, the latter accepting names like `Win11` or numeric `Major.Minor`). Descriptive metadata only - generated code is unchanged. CLI-only, no directive form.

### [Embed a file at compile time - `$embedstr` / `$embedbytes`](embed.md)

`{$embedstr NAME 'path'}` emits `const NAME: String = '...';` and `{$embedbytes NAME 'path'}` emits `const NAME: array[0..N-1] of byte = (...);`, reading the file as raw bytes at compile time - the asset ships inside the binary, no runtime file I/O. Each has a 1-arg form emitting a bare value expression for inline use. Path resolution matches `{$I}`. Available in every mode, no modeswitch.

---

## Strings and literals

### [Multiline Strings](multiline-strings.md)

Two delimiter forms for literals spanning source lines without manual `+` or `LineEnding`: backtick `` `...` `` (byte-exact, no trimming by default) and triple-quote `'''...'''` (indentation auto-stripped to the closing delimiter's column). Companion directives tune the line ending baked in and the backtick trimming. Modeswitch `multilinestrings`.

---

## Tweaks and quality of life

### [Compound Assignment](compound-assignment.md)

Modify-and-assign for every operator, in three layers: the word-based operators `div=`, `mod=`, `and=`, `or=`, `xor=`, `shl=`, `shr=` (every mode, no switch); the C-style `+=`, `-=`, `*=`, `/=` (on automatically in unleashed, `{$coperators on}` elsewhere); and properties as targets, where `prop += x` and `inc(prop, n)` expand to getter-plus-setter calls that stock FPC rejects (unleashed-only).

### [Indexed Labels and Lazy Labels](indexed-labels.md)

Declare a family of labels keyed by ordinal ranges (`label state[0..4]`) or strings (`label action['start', 'stop']`) and jump to them by index - a runtime index compiles to a case dispatch, ideal for state machines and jump tables. In unleashed mode labels also no longer need declaring before use (`goto done;` works without a prior `label`). Available whenever `{$goto on}` is active; lazy labels are unleashed-only.

### [Tweaks](tweaks.md)

Small semantic adjustments that make standard constructs behave the way most people expect, all unleashed-mode-only: the **preserved for-loop counter** (after `for i := 1 to N do ... break;` the counter keeps its value, undefined in stock Pascal), the **`is not` / `not in`** operators (shorthand for the parenthesized negation), and the module switches (`goto`, C-operators, macros) that unleashed turns on automatically.
