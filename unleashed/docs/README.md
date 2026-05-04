# FPC Unleashed - Documentation

Detailed documentation for each feature in FPC Unleashed. Every feature has its own page with the full grammar, semantics, examples, and the modeswitch that gates it. All listed modeswitches are enabled by default in `{$mode unleashed}`; most can also be opted into from `objfpc` / `delphi` via `{$modeswitch ...}`.

## [Inline Variables](inline-vars.md)

Declare variables at point of first use inside any statement block, with explicit types, type inference (`var x := expr`), or as for-loop counters. Scope is the enclosing `begin..end`, with shadowing rules and interaction with the existing `var` section spelled out in detail.

Enabled via `{$modeswitch inlinevars}`.

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

## [Compound Assignment Operators](compound-assignment.md)

Word-based modify-and-assign operators that the standard set is missing: `div=`, `mod=`, `and=`, `or=`, `xor=`, `shl=`, `shr=`.

Always available in every mode; no modeswitch and independent of `{$coperators on}`.

## [Indexed Labels & Lazy Labels](indexed-labels.md)

Declare arrays of labels with numeric ranges (`label state[0..4]`) or string keys (`label action['start', 'stop']`) and jump to them by index. Useful for dispatch tables and state machines.

Available whenever `{$goto on}` is active; no dedicated modeswitch.

## [Tweaks](tweaks.md)

Small semantic adjustments that make standard Pascal constructs behave the way most people expect them to. No dedicated modeswitch - these are unleashed-mode-only. Currently covers the preserved for-loop counter (`for i := 1 to N do ... break;` keeps the right value of `i` after the loop), with more entries to follow.

## [Extra Improvements](extra-improvements.md)

Catch-all page for smaller, targeted improvements that unlock Pascal patterns standard FPC modes reject - e.g. string-to-ordinal typecast in constant expressions (`dword('RIFF')`), or Delphi-style implicit `generic` / `specialize` syntax made available in any mode via `{$modeswitch implicitgenerics}`. Some entries are gated on their own modeswitch (and enabled by default in `unleashed`), others are `unleashed`-only with no separate switch; each entry on the page states which.

## [Multiline Strings](multiline-strings.md)

Two delimiter forms for string literals spanning multiple source lines without manual `+` or `LineEnding`: backtick `` `...` `` (extended literal, embedded newlines tolerated) and a separate triple-quote form with indentation handling. They differ in tokenization and composition rules - the page covers both in depth, including escaping and interaction with concatenation. Stock FPC actually accepts these but never documented them; this page fills that gap.

Enabled via `{$modeswitch multilinestrings}`.
