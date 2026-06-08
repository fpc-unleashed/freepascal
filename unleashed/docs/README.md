# FPC Unleashed - Documentation

Detailed documentation for each feature in FPC Unleashed. Every feature has its own page with the full grammar, semantics, examples, and the modeswitch that gates it. All listed modeswitches are enabled by default in `{$mode unleashed}`; most can also be opted into from `objfpc` / `delphi` via `{$modeswitch ...}`.

## [Inline Variables](inline-vars.md)

Declare variables at point of first use inside any statement block, with explicit types, type inference (`var x := expr`), or as for-loop counters. Scope is the enclosing `begin..end`, with shadowing rules and interaction with the existing `var` section spelled out in detail.

Enabled via `{$modeswitch inlinevars}`.

## [Thread-Static Variables](thread-static.md)

`threadstatic` declares a per-thread variable with program lifetime and block-local source scope (the sym lives in the declaring routine's localst, so it is invisible to sibling routines, the same as `var`). Two forms with identical semantics: an inline statement (`threadstatic name := expr;` anywhere in a body) and a declaration section before the body (parallel to `var` / `static`, supporting multiple names and zero-init). Each thread sees its own copy via FPC's TLS infrastructure (`FPC_THREADVAR_RELOCATE`, `FPC_THREADVARTABLES`); init runs once per thread on first reach via a per-thread Boolean guard, so a raised init leaves that thread's variable zeroed and is not retried for that thread. The const-init data-segment fast path that regular `static` uses does not apply - TLS has no per-thread template, so even a literal `threadstatic x := 5;` is a runtime per-thread assignment.

Enabled via `{$modeswitch threadstatic}` (on by default in `unleashed`).

## [Static Variables](static-section.md)

A writeable `static` storage class with program-wide lifetime but block-local scope - the same idea as C's `static int x;` inside a function. Two flavors: a `static` declaration section (parallel to `var` / `const`, compile-time initializers, zero runtime cost) and a single-statement `static name := expr;` inline form (anywhere in a body, runtime initializers via a one-shot guard set true before the assignment, so a raised init leaves the variable zeroed and is not retried). Allowed only inside function / procedure / method bodies; at unit / program level plain `var` already gives the same lifetime and is the right tool.

Enabled via `{$modeswitch staticsection}` and `{$modeswitch inlinestatic}` (both on by default in `unleashed`).

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

## [Multi-Variable Initialization](multi-var-init.md)

Initialize several variables of the same type in one declaration, e.g. `a, b, c: integer = 42;`. Works in `var`, typed constants, and inline `var`. Each variable gets an independent copy of the value - assigning to one does not affect the others.

Enabled via `{$modeswitch multivarinit}`.

## [For-Step](forstep.md)

`step N` clause in `for` loops to advance the counter by an arbitrary positive amount on each iteration. Works with `to` and `downto`, with inline `var`, and with all control-flow constructs (`break`, `continue`, `exit`, `raise`). The step expression is evaluated once before the loop starts; constant `step 1` folds back to a regular for-loop. `step` is a context-sensitive keyword - only recognized between the `to` / `downto` expression and `do`, so existing code with a `step` variable / function / field keeps compiling.

Enabled via `{$modeswitch forstep}`.

## [Flexible Array Members](flexible-arrays.md)

C99-style records with a variable-length tail: `data: array[] of T` as the last field. The fixed header has the size `sizeof` reports; the tail extends as far as the allocation says it does, and indexing skips range checks because the FAM has no upper bound. Allocation is a single `GetMem(rec, sizeof(rec)+payload)`, no separate buffer or pointer chase. Useful for Win32 structures with trailing arrays (`TOKEN_GROUPS`, `BITMAPINFO`, ...), network frames, file headers, and inline payloads.

Enabled via `{$modeswitch flexiblearrays}`.

## [Compound Assignment Operators](compound-assignment.md)

Word-based modify-and-assign operators that the standard set is missing: `div=`, `mod=`, `and=`, `or=`, `xor=`, `shl=`, `shr=`.

Always available in every mode; no modeswitch and independent of `{$coperators on}`.

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
