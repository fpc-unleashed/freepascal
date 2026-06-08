# FPC Unleashed - Documentation

Detailed documentation for each feature in FPC Unleashed. Every feature has its own page with the full grammar, semantics, examples, and the modeswitch that gates it. All listed modeswitches are enabled by default in `{$mode unleashed}`; most can also be opted into from `objfpc` / `delphi` via `{$modeswitch ...}`.

## [Inline Variables](inline-vars.md)

Declare variables at point of first use inside any statement block, with explicit types, type inference (`var x := expr`), or as for-loop counters. Inline `const` works the same way: `const K = expr` yields a true compile-time constant, `const K: T = v` a typed constant with block-scoped storage. Both vars and consts are block-scoped to the enclosing `begin..end`, with shadowing rules and interaction with the existing `var` section spelled out in detail.

Enabled via `{$modeswitch inlinevars}`.

## [Thread-Static Variables](thread-static.md)

`threadstatic` declares a per-thread variable with program lifetime and block-local source scope (the sym lives in the declaring routine's localst, so it is invisible to sibling routines, the same as `var`). Two forms with identical semantics: an inline statement (`threadstatic name := expr;` anywhere in a body) and a declaration section before the body (parallel to `var` / `static`, supporting multiple names and zero-init). Each thread sees its own copy via FPC's TLS infrastructure (`FPC_THREADVAR_RELOCATE`, `FPC_THREADVARTABLES`); init runs once per thread on first reach via a per-thread Boolean guard, so a raised init leaves that thread's variable zeroed and is not retried for that thread. The const-init data-segment fast path that regular `static` uses does not apply to a non-zero value - TLS has no per-thread template, so `threadstatic x := 5;` is a runtime per-thread assignment. A zero-valued constant (`= 0`, `= nil`, `= false`, `= ''`) is the exception: the per-thread block is zero-allocated, so the guard is dropped.

Enabled via `{$modeswitch threadstatic}` (on by default in `unleashed`). `tstatic` is a short alias for `threadstatic`, accepted in both the inline and section forms.

## [Static Variables](static-section.md)

A writeable `static` storage class with program-wide lifetime but block-local scope - the same idea as C's `static int x;` inside a function. Two flavors: a `static` declaration section (parallel to `var` / `const`, compile-time initializers, zero runtime cost) and a single-statement `static name := expr;` inline form (anywhere in a body, runtime initializers via a one-shot guard set true before the assignment, so a raised init leaves the variable zeroed and is not retried). Allowed only inside function / procedure / method bodies; at unit / program level plain `var` already gives the same lifetime and is the right tool.

Enabled via `{$modeswitch staticsection}` and `{$modeswitch inlinestatic}` (both on by default in `unleashed`).

## [Out-Variables](out-var.md)

Declare a variable inline at an `out`-argument position (`Foo(var x)`), with its type inferred from the parameter and scoped to the enclosing block, or discard the output entirely with `_`. Accepted only at an `out` parameter (value / var / const are rejected); the type is resolved after overload selection, so overloads differing only in the out type are ambiguous; a name already in scope is a duplicate. A declared identifier `_` always wins over the discard meaning, and intrinsics (`Write`, `Str`, ...) take no discards at all, so existing code is unaffected. Captured and discarded managed-type outputs are ordinary locals, initialised and finalised normally. No throwaway variable pre-declared for each output.

Enabled via `{$modeswitch outvar}`.

## [Anonymous Tuples](tuples.md)

Lightweight anonymous record types written in parentheses, e.g. `(Integer, String)` or `(name: string; age: integer)`. Supports tuple literals, destructuring assignment, comparison, and works wherever a record works (function results, parameters, fields). Built on the existing record infrastructure, so managed types, copy semantics, and calling conventions are inherited for free.

Enabled via `{$modeswitch tuples}`.

## [Statement Expressions](statement-expressions.md)

Use `if`, `case`, and `try` as expressions that yield a value, so you can drop temporary variables for conditional assignment. Multi-statement branches use `begin..end` and the last expression in the block is the result.

Enabled via `{$modeswitch statementexpressions}`.

## [Match Statement](match.md)

Pattern matching with first-match semantics that replaces `case..of` for non-ordinal subjects (tuples, strings, arbitrary expressions). Adds catch-all (`_` / `else`), tuple wildcard patterns, condition-based branches, fallthrough mode, and an expression form that yields a value.

Enabled via `{$modeswitch match}`.

## [Scoped Cleanup - defer, autofree, scoped with](autofree.md)

`defer STATEMENT` registers an action to fire at scope exit (LIFO, runs on normal exit / exception / break / continue / `exit`). `autofree EXPR` is sugar that turns a freshly-allocated class instance into a scoped resource with automatic `Free`. The `with` statement gains inline-var bindings (`with var x := autofree T.Create do ...`) so the holder is named, scoped, and cleaned up in one line. Cleanup uses a nil-guarded pattern so manual `x.Free` earlier in the scope does not double-free.

Enabled via `{$modeswitch autofree}`.

## [Lock](lock.md)

`lock ... do <stmt>;` wraps a statement or block with `EnterCriticalSection / try .. finally / LeaveCriticalSection` so it is serialized across threads - it blocks until acquired and cannot fail. `trylock ... do <stmt> else <stmt>;` may miss (one immediate attempt by default, a bounded wait with `wait N` - Int64 milliseconds) and then runs the mandatory `else` branch without the lock. Targets: bare form per-callsite (hidden CS unique to that source position, "only one thread executes this code"); `lock(globalVar)` per-variable (hidden CS shared across every site naming that variable, "only one thread touches this data"); `lock(MyCS)` explicit, where `MyCS: TRTLCriticalSection` and the user manages Init/Done. Multi-target form `lock(a, b, c)` sorts the lock order by name across all sites so AB-vs-BA deadlock is impossible; multi-target `trylock` is all-or-nothing with rollback. The wait machinery uses only `system`-unit primitives (no SysUtils, no clock reads). Hidden CS storage lives in the unit's localsymtable and is wired into the unit's `initialization` / `finalization` sections automatically. Critical section is recursive on every supported target so nesting on the same variable does not self-deadlock.

Enabled via `{$modeswitch lock}`.

## [Async / Await - thread futures](async-await.md)

`async <call>` / `async begin..end` runs work on a fresh worker thread and returns a `future of T` (or a bare `future`); `await f` blocks until the worker finishes and reads its result. This is the `std::async` model (one thread per `async`, one join per `await`), not C# async - there is no function coloring and no event loop. The call form snapshots the call's arguments by value at the spawn point; the block form captures referenced locals by reference through the function-reference machinery, so the future may outlive the routine that spawned it. Awaiting is repeatable (the result is cached, the event re-armed). A worker exception is re-raised on the caller at the first `await`; a fire-and-forget future swallows it. The future also carries a control surface: `Cancel` raises a cooperative flag (readable inside `async begin..end` as `Cancelled`), `Done` polls completion without blocking, `ThreadID` hands the worker to the RTL thread API. Built entirely on `system`-unit thread primitives (`BeginThread`, `RTLEvent*`, `AcquireExceptionObject`) with no RTL changes; on Unix the program needs a threading driver (`cthreads`).

Enabled via `{$modeswitch asyncawait}`.

## [Parallel For](parallelfor.md)

`for parallel [(N)] var i := lo to|downto hi [step s] [chunk c] do STMT` runs the loop body across a `BeginThread` worker pool. Iterations are claimed in chunks from a shared atomic counter (each runs exactly once, order undefined; `chunk c` sets the grab size, default about four grabs per worker), the calling thread joins in as a worker, and the loop is a barrier - it returns only after every iteration has finished. Optional pool size `(N)` clamps to `[1, min(count, 256)]`; the default is `min(GetCPUCount, count)`; `parallel(1)` is plain sequential. The body is hoisted into a hidden nested routine so it can reach the enclosing routine's locals (concurrently, so shared writes need atomics or a lock), and sees `WorkerIndex` / `WorkerCount` for per-worker private state. The dispatch follows the loop variable's width, so int64 ranges past 2^31 work, as do enum and char counters. `downto` and `step` compose; the loop variable must be inline (`var`); `continue` works, `break` cancels cooperatively (no new iterations start, running ones finish), `exit` / `goto`-out and `for ... in` are rejected. The first exception raised on any worker is re-raised on the caller after the barrier; a failed thread spawn just means fewer workers. A parallel loop nested inside another runs its inner body sequentially by default (an explicit `(N)` opts back in) so the thread count stays bounded.

Enabled via `{$modeswitch parallelfor}`.

## [Multi-Variable Initialization](multi-var-init.md)

Initialize several variables of the same type in one declaration, e.g. `a, b, c: integer = 42;`. Works in `var`, typed constants, and inline `var`. Each variable gets an independent copy of the value - assigning to one does not affect the others.

Enabled via `{$modeswitch multivarinit}`.

## [For-Step](forstep.md)

`step N` clause in `for` loops to advance the counter by an arbitrary positive amount on each iteration. Works with `to` and `downto`, with inline `var`, and with all control-flow constructs (`break`, `continue`, `exit`, `raise`). The step expression is evaluated once before the loop starts; constant `step 1` folds back to a regular for-loop. `step` is a context-sensitive keyword - only recognized between the `to` / `downto` expression and `do`, so existing code with a `step` variable / function / field keeps compiling.

Enabled via `{$modeswitch forstep}`.

## [Flexible Array Members](flexible-arrays.md)

C99-style records with a variable-length tail: `data: array[] of T` as the last field. The fixed header has the size `sizeof` reports; the tail extends as far as the allocation says it does, and indexing skips range checks because the FAM has no upper bound. Allocation is a single `GetMem(rec, sizeof(rec)+payload)`, no separate buffer or pointer chase. Useful for Win32 structures with trailing arrays (`TOKEN_GROUPS`, `BITMAPINFO`, ...), network frames, file headers, and inline payloads.

Enabled via `{$modeswitch flexiblearrays}`.

## [Int128 / UInt128](int128.md)

Native 128-bit signed and unsigned integers that behave like any other ordinal - literals, arithmetic, `div` / `mod`, shifts, bitwise, comparisons, `inc` / `dec` / `succ` / `pred`, `abs` / `odd` / `sqr`, `for`, `case`, range / overflow checks, `Str` / `Val`, and `Write` / `Read`. 128-bit literals are gated by the switch; the types are always available. On the 64-bit register targets the common operations are inline register-pair code; `div` / `mod`, overflow-checked `mul` / `neg` and `Str` / `Val` stay RTL helpers (the gcc `__divti3` model), and the remaining CPUs run entirely on the helpers.

Enabled via `{$modeswitch int128}`.

## [Compound Assignment Operators](compound-assignment.md)

Word-based modify-and-assign operators that the standard set is missing: `div=`, `mod=`, `and=`, `or=`, `xor=`, `shl=`, `shr=`.

Always available in every mode; no modeswitch and independent of `{$coperators on}`.

## [zeroinit Procedure Modifier](zeroinit.md)

`procedure foo; zeroinit;` injects an implicit `Default(typeof(local))` assignment for every local variable at function entry, scaling automatically as locals are added or removed. Scales over stand-alone routines, methods, constructors, and destructors. The function `Result` is included, and anonymous compound types (inline `array[..] of T` / `record ... end` without a named alias) are covered like any other local. File-type locals keep their RTL init (their proper closed state is not all-zeros). Mutually exclusive with `external`, `interrupt`, and `assembler`. Reads of locals inside the routine no longer raise the uninitialised-variable warning.

Unleashed-mode only; no separate modeswitch.

## [SwapValues Intrinsic](swapvalues.md)

Builtin `SwapValues(a, b)` that swaps two same-typed assignable variables with a bitwise move, callable with no `uses` beyond the implicit `System` unit. For managed types (string, dynamic array, interface, Variant) it swaps the reference words with zero `incr_ref` / `decr_ref` churn; ordinals and pointer-sized operands lower to a register swap, larger types to a raw byte exchange. The point is to swap without dragging in SysUtils (`Swap<T>` / `Exchange<T>`) and its exception and handler setup. `SwapValues` is a fresh name with no RTL clash, and a user-declared `SwapValues` symbol shadows the builtin, so it never breaks existing code.

Unleashed-mode only; no separate modeswitch.

## [Type() Intrinsic](type-intrinsic.md)

Compile-time `Type(expr)` that yields the static type of an expression without evaluating it. Works in every type-bearing position: `var y: Type(x);`, fields, parameters, function results, typecasts (`Type(x)(v)`), arguments to `SizeOf` / `High` / `Low` / `Default`, and derived types (`array of Type(x)`, `^Type(x)`, `set of Type(x)`, generic specialisation arguments). The operand is parsed and type-checked but never reaches code generation, so `Type(a[0])` is safe on an empty dynamic array, `Type(SomeFunc())` does not call `SomeFunc`, and range checks never fire on the operand. Composes with inline-var type inference, so a single `var z := ...` site can drive multiple downstream declarations spelled `Type(z)`. Disambiguated from the `type` keyword purely by the trailing `(`, so `type X = type Y` strong aliases and ordinary type sections keep working unchanged.

Unleashed-mode only; no separate modeswitch.

## [Indexed Labels & Lazy Labels](indexed-labels.md)

Declare arrays of labels with numeric ranges (`label state[0..4]`) or string keys (`label action['start', 'stop']`) and jump to them by index. Useful for dispatch tables and state machines.

Available whenever `{$goto on}` is active; no dedicated modeswitch.

## [Composable Records](composable-records.md)

Record composition without duplicating fields, plus C-style memory overlap and per-field layout control. Three composition forms - `embed TBase;` flattens fields of an existing record into the outer scope (declaration-time duplicate detection rejects name collisions), `record fields end;` (and `packed`/`bitpacked` variants) does the same for an inline anonymous record, the classic `name: T;` keeps the regular named subfield. Modern `union ... end;` replaces `case TYPE of` for plain memory overlap, can appear anywhere in the body, multiple unions per record allowed; optional `union size N` (assert + pad in bytes) / `union bitsize N` (assert in bits, byte storage) / `union align N` (cache-line placement) / `union of TYPE` (size+align+default type anchor) modifiers. `bitpacked record of TYPE` plus innermost-wins propagation enables C-style `name: N;` bitfield syntax inside (translates to `name: T bitsize N`) and `pad N;` / `pad 0;` anonymous padding / alignment markers. Per-field modifiers `align N` / `bitalign N` / `size N` / `bitsize N` give byte- and bit-level layout control for faithful WinAPI / POSIX struct ports. `OffsetOf()` / `BitOffsetOf()` / `AlignOf()` / `BitAlignOf()` / `BitSizeOf()` intrinsics for compile-time layout introspection, honouring per-field overrides where applicable. `GetMemAligned` / `AllocMemAligned` / `ReAllocMemAligned` / `FreeMemAligned` in the `system` unit deliver aligned heap allocation for cache-line patterns.

Enabled via `{$modeswitch composablerecords}`.

## [Auto-Properties](auto-properties.md)

A property with a type but no `read` / `write` clause synthesizes a `strict private` backing field named `F` + the property name and binds the property straight to it (`read FName write FName`) - no getter / setter method, identical code to a hand-written field-backed property. A trailing `readonly` / `writeonly` directive after the property's semicolon (`property Id: Integer; readonly;`, like a procedure directive) narrows it to a single direction; both are soft keywords. A `= constexpr` after the type seeds the backing field at construction (`property Port: Integer = 8080;`), before the constructor body so a constructor can override it. Class properties get a `class var` backing field, records get an ordinary field, and published auto-properties are RTTI-complete. The backing field is a real member reachable by name from the declaring type's methods. Collisions, indexed bare properties, and `readonly; writeonly;` together are compile errors.

Enabled via `{$modeswitch autoproperties}`.

## [Lightweight Generics](lightgenerics.md)

Drops the duplicated-body cost of stock monomorphization. The compiler buckets each type parameter into an ABI shape class - `Shape_Ref`, `Shape_POD_1/2/4/8`, `Shape_Managed`, `Shape_Complex` - and emits one method body per (bucket, method) pair instead of one per specialization. Class specializations whose every type parameter is `Shape_Ref` (class refs, interfaces, raw pointers, classref, procvar, dynamic arrays) share, as do specializations whose parameters all land in the same `Shape_POD_N` bucket (`TCell<Integer>` and `TCell<LongWord>` reuse one body; `TCell<Int64>` keeps its own). Multi-parameter generics match on a composite key (one shape per parameter in order), and sharing covers instance/class/static methods, constructors, destructors, property accessors, generic records, standalone generic functions, and cross-module specializations. Distinct specializations keep distinct types, distinct VMTs and distinct RTTI, but their VMT slots and call sites all resolve to the same code address. Floats are excluded (fpu/xmm ABI); managed specializations share any body that does not assign the type parameter, and fall back to per-type code for the bodies that do.

Opt-in via `{$modeswitch lightgenerics}` - not in the default unleashed set yet.

## [Tweaks](tweaks.md)

Small semantic adjustments that make standard Pascal constructs behave the way most people expect them to. No dedicated modeswitch - these are unleashed-mode-only. Currently covers the preserved for-loop counter (`for i := 1 to N do ... break;` keeps the right value of `i` after the loop), with more entries to follow.

## [Extra Improvements](extra-improvements.md)

Catch-all page for smaller, targeted improvements that unlock Pascal patterns standard FPC modes reject - e.g. string-to-ordinal typecast in constant expressions (`dword('RIFF')`), Delphi-style implicit `generic` / `specialize` syntax made available in any mode via `{$modeswitch implicitgenerics}`, or the `array[N] of T` shorthand for `array[0..N-1] of T`. Some entries are gated on their own modeswitch (and enabled by default in `unleashed`), others are `unleashed`-only with no separate switch; each entry on the page states which.

## [Multiline Strings](multiline-strings.md)

Two delimiter forms for string literals spanning multiple source lines without manual `+` or `LineEnding`: backtick `` `...` `` (extended literal, embedded newlines tolerated) and a separate triple-quote form with indentation handling. They differ in tokenization and composition rules - the page covers both in depth, including escaping and interaction with concatenation. Stock FPC actually accepts these but never documented them; this page fills that gap.

Enabled via `{$modeswitch multilinestrings}`.

## [String Interpolation](string-interpolation.md)

Embed expressions inside a string literal using `$'Hello {name}, age {age:%2d}'`. Two placeholder forms: bare `{expr}` (auto-format by type) and `{expr:mask}` where the mask is the raw text after the first `:` (Format / FormatDateTime / FormatFloat / IntToHex picked by type and mask shape). Default locale is invariant (`L` prefix opts into the system locale). The page covers the full type x mask dispatch table, escaping rules, required units, and notes for users coming from C# / Python / JavaScript.

Enabled via `{$modeswitch interpolatedstrings}`.

## [Strip RTTI](strip-rtti.md)

Replaces type-name strings emitted into RTTI / VMT structures with empty strings, so an ASCII dump of the binary no longer reveals the program's internal type structure. Comes with three whitelisting mechanisms: the `expose` keyword (per-declaration), the `{$rttiexpose}` directive (per-unit glob list), and the `--rttiexpose=` CLI flag (global glob list). The whitelisting decision is precomputed once per type at parse time and stored as a flag on the `tdef`, so RTTI emit stays cheap.

Enabled via `{$modeswitch striprtti}`. Off by default in `unleashed` mode.

## [Custom Binary Metadata](binary-metadata.md)

Three CLI flags that override metadata fields the compiler embeds into the produced binary: `--fpcsignature=` (the `.fpc.version` ident string, every target), `--linkerversion=` (PE optional header linker version, Windows only), `--osversion=` (PE optional header minimum OS version, Windows only, accepts symbolic names like `Win11` or numeric `Major.Minor`). Useful for distribution branding, build mimicry, and loader gating.

CLI-only; no directive form.

## [Embed file at compile time - `$embedstr` / `$embedbytes`](embed.md)

`{$embedstr NAME 'path'}` emits `const NAME: String = '...';` and `{$embedbytes NAME 'path'}` emits `const NAME: array[0..N-1] of byte = (...);` at the directive site, reading the file as raw bytes. Each also has a 1-arg form (`{$embedstr 'path'}` / `{$embedbytes 'path'}`) that emits a bare value expression - a String or a `[$xx,...]` array literal - usable as an inline function argument or comparison operand. Path resolution matches `{$I}`. Use `$embedstr` for text / move-out-of buffers, `$embedbytes` when an API wants `array of byte`.

Directive only; available in every mode.

## [Introduced Functions, Procedures and Intrinsics](introduced-functions.md)

Reference table of identifiers FPC Unleashed adds on top of stock FPC and that user code can call without an extra `uses`: compile-time intrinsics (`OffsetOf`, `BitOffsetOf`, `AlignOf`, `BitAlignOf`, extended `BitSizeOf`), and the aligned heap allocator in the `system` unit (`GetMemAligned`, `AllocMemAligned`, `ReAllocMemAligned`, `FreeMemAligned`). Each row lists the signature, category (intrinsic / RTL `system` / other RTL unit), gating modeswitch, and the feature page that covers the surrounding context.
