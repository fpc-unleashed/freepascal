# `threadstatic` Variables

`threadstatic` declares a per-thread variable with program lifetime and block-local source scope. Each thread sees its own copy; the initializer runs once per thread, on first reach, behind a per-thread guard. Two forms with identical semantics: an inline statement (`threadstatic name := expr;` anywhere in a body) and a declaration section before the body (parallel to `var` / `static`). `tstatic` is a short alias accepted in every position the long form is.

Modeswitch: `threadstatic`, enabled by default in `{$mode unleashed}`. Elsewhere:

```pascal
{$mode objfpc}
{$modeswitch threadstatic}
```

Allowed only inside function / procedure / method bodies. Both `threadstatic` and `tstatic` are soft keywords (not reserved in any mode), so existing user identifiers with those names keep working, and `tstatic` is a keyword only while the modeswitch is active.

## Basic usage

```pascal
function nextId: integer;
begin
  threadstatic next := 1000; // per-thread counter
  result := next;
  inc(next);
end;
```

In a single thread this behaves like a program-wide counter that survives between calls. In a multi-threaded program each thread gets its own `next` starting at 1000 - no bleed in either direction. The same routine with the declaration section:

```pascal
function nextId: integer;
threadstatic
  next: integer = 1000;
begin
  result := next;
  inc(next);
end;
```

## Syntax forms

Inline statement form (inside the body):

```
threadstatic name : Type;            // zero-init per thread
threadstatic name : Type := expr;    // explicit type + init per thread
threadstatic name := expr;           // inferred type + init per thread
```

Declaration section form (before the body, like `var` / `static`):

```
threadstatic
  name : Type;                       // zero-init per thread
  a, b, c : Type;                    // several names, each its own per-thread copy
  name : Type = expr;                // explicit type + init per thread
  a, b, c : Type = expr;             // each name initialized to expr per thread
  name := expr;                      // inferred type + init per thread (single name)
```

The section uses `= expr` for the typed form (matching `var` / `const` / `static` sections) and `:= expr` for the inferred single-name form; the inline statement always uses `:=`. Type inference follows inline-var rules: character literal promotes to the default string type, sub-32-bit integers promote to `LongInt`, an explicit cast (`threadstatic b := Byte(10);`) suppresses promotion.

Because `threadstatic` is a soft keyword, place its section **before** any `const` / `var` / `threadvar` section in the same routine - a preceding one of those would consume the word as a declaration name. A following `var` / `const` is fine (same ordering rule as the `static` section).

A section initializer is still a runtime per-thread assignment (no data-segment fast path, see below), so `expr` may be any expression, not only a compile-time constant. Both forms can be mixed in one routine.

## Short alias `tstatic`

`tstatic` resolves to the same soft keyword, is gated on the same modeswitch, and produces identical code:

```pascal
function nextId: integer;
begin
  tstatic next := 1000; // inline form
  result := next;
  inc(next);
end;

function stats: integer;
tstatic
  n: integer = 5;              // section form
  a, b: integer;               // multi-name, zero-init per thread
begin
  ...
end;
```

The spellings are interchangeable; pick one per routine for readability. A routine may have one section (under either spelling) plus any number of inline declarations.

## Per-thread guard, init exactly once per thread

The compiler emits a hidden Boolean guard that is itself a threadvar, so every thread has its own. Generated logic:

```pascal
if not __guard_per_thread then begin
  __guard_per_thread := true; // set BEFORE evaluating the expression
  __var_per_thread := <expr>;
end;
```

- The init expression runs **once per thread**, on the first reach of the declaration in that thread.
- If `<expr>` raises, the exception propagates, that thread's variable keeps its zero bytes, and the guard is already true - no retry for that thread. Other threads still run their own init independently.

## Lazy init that outside code may pre-empt

`threadstatic` is the natural tool for per-thread lazy init (seed-on-first-use, per-thread cache, per-thread handle). But its guard fires on **first reach**, not at thread start - if an outside caller may initialize the same underlying state earlier, make the init *conditional on the state*, never an unconditional overwrite.

A per-thread RNG is the canonical case: seeding from OS entropy on first draw is the right default, but an explicit `seed(x)` called before the first draw must survive. The state stays a unit-level `threadvar` (several routines share it); the threadstatic carries only the once-per-thread trigger:

```pascal
threadvar rngState: array[0..3] of qword; // shared by the generators

procedure seed(x: qword);          // an outside caller may run this first
begin
  expand(rngState, x);             // never leaves rngState all-zero
end;

function lazySeed: boolean;
begin
  // all-zero == nobody seeded this thread yet; a prior seed(x) is kept
  if allZero(rngState) then expand(rngState, osEntropy);
  result := true;
end;

function nextRandom: qword;
begin
  threadstatic primed := lazySeed; // runs lazySeed at most once per thread
  ...
end;
```

An unconditional `threadstatic primed := expand(rngState, osEntropy)` would be wrong: on `seed(x); nextRandom` the guard trips inside `nextRandom`, *after* `seed`, and the entropy would overwrite `x`. The state check is what makes seed-before-first-use work; the threadstatic still keeps that check off the per-call hot path.

## Storage and registration

The hidden variable carries `vo_is_thread_var`, so codegen routes loads and stores through the threadvar relocation mechanism, and the slot is registered in `FPC_THREADVARTABLES` at unit / program init exactly like a classic top-level `threadvar`.

On win32 / win64 the access fast path is inlined as a read of the running thread's threadvar block from the TEB TLS slot array plus the variable offset; the helper call is reached only when the block has not been allocated for the thread yet. With the address hoisted out of a loop (`-O2` does that), a threadstatic access costs the same as a global.

The sym lives in its declaring routine's local symtable, so it follows normal Pascal scoping and is invisible to sibling routines. Registration still works because the parser also appends every threadstatic sym to a module-level list that `InsertThreadvars` walks when building `FPC_THREADVARTABLES`. The inline form emits its guarded init at the declaration point; the section form collects its init nodes and splices them to the front of the body, running on entry.

### Debugger support

On win32 / win64 the DWARF location is split: `DW_AT_location` stays a plain static address (a debugger that cannot reach the TEB keeps showing the template value without erroring), and a vendor attribute `DW_AT_FPC_threadvar` carries the real per-thread expression - reading the running thread's block through the TEB (gs base on win64, fs base on win32) with a fallback to the static template while the program is still single threaded. fpdebug (Lazarus) evaluates the vendor attribute and shows each thread its own value; other debuggers ignore it. On native-TLS targets (Linux and the other Unix systems) the compiler emits the standard `DW_OP_GNU_push_tls_address` location, which gdb resolves out of the box.

## No const-init fast path (one exception)

Regular `static` short-circuits a compile-time-constant initializer into the typed-constant data segment - no guard, no branch. Thread-static cannot do that for a non-zero value: FPC's TLS layout has no per-thread template, so `threadstatic x := 5;` needs the guarded runtime assignment to apply the 5 in every thread. Cost: one branch on first use per thread, free thereafter.

The one case that matches `static`: an initializer folding to all-zero bytes (`= 0`, `= nil`, `= false`, `= ''`, empty set). The per-thread block is zero-allocated by the RTL, so the value is already there - the compiler drops both the guard and the assignment, exactly as if no initializer were given.

## Comparison

| Form | Lifetime | Scope | Per | Cost |
|---|---|---|---|---|
| `var x: T;` (in body) | call | block | call | stack alloc |
| `threadvar x: T;` (top-level) | program | unit | thread | BSS + TLS relocate |
| `static name := V;` | program | block | program | data segment (const init) / BSS + guard (runtime init) |
| `threadstatic name := V;` | program | block | thread | TLS + per-thread guard |

## Limitations

- In an anonymous-function body the keyword is parsed but the resulting threadvar is not wired into the closure capturer (same gap as anonymous-function `static`).
- No TLS template / `.tdata` init: every non-zero initializer is a runtime per-thread assignment, even when the expression is a compile-time constant.
- Aggregate typed-constant initializers (`array` / `record` literals via `= (...)`) are not supported in either form.

## Demo

```pascal
program thread_static_demo;

{$mode unleashed}

function nextId: integer;
begin
  threadstatic next := 1000; // each thread counts from 1000 independently
  result := next;
  inc(next);
end;

function takeThree(const tag: string): string;
begin
  result := tag;
  for var i := 1 to 3 do result += $' {nextId}';
end;

begin
  var a := async takeThree('worker A:');
  var b := async takeThree('worker B:');
  writeln(await a);
  writeln(await b);
  writeln('main   : ', nextId, ' ', nextId);
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output (deterministic - every thread owns its counter):

```
worker A: 1000 1001 1002
worker B: 1000 1001 1002
main   : 1000 1001
```
