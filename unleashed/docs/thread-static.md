# Thread-Static Variables

`threadstatic` declares a per-thread variable with program lifetime and block-local source scope. Each thread sees its own copy; init runs once per thread on first reach via a per-thread guard. Two forms, same semantics: an inline statement (`threadstatic name := expr;` anywhere in a body) and a declaration section before the body (parallel to `var` / `static`). `tstatic` is a short alias for `threadstatic`, accepted in every form (see [Short alias `tstatic`](#short-alias-tstatic)).

Gated by modeswitch `THREADSTATIC`, enabled by default in `{$mode unleashed}`. Outside unleashed:

```pas
{$mode objfpc}
{$modeswitch threadstatic}
```

Allowed only inside a function / procedure / method body. Both `threadstatic` and `tstatic` are soft keywords (not reserved in any mode), so user identifiers called `threadstatic` or `tstatic` are not shadowed, and `tstatic` is only a keyword when the modeswitch is active.

## Basic usage

```pas
function NextId: Integer;
begin
  threadstatic next := 1000;   // per-thread counter
  Result := next;
  Inc(next);
end;
```

In a single thread this behaves like a program-wide counter that survives between calls. In a multi-threaded program each thread gets its own `next` starting at 1000.

The same routine written with the declaration section:

```pas
function NextId: Integer;
threadstatic
  next: Integer = 1000;
begin
  Result := next;
  Inc(next);
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

The section uses `= expr` for the typed form (matching `var` / `const` / `static` sections) and `:= expr` for the inferred single-name form. The inline statement uses `:= expr` in both cases. Type inference follows inline-var rules: bare character literal -> default string type, sub-Int32 integers promote to LongInt, explicit casts suppress promotion.

Because `threadstatic` is a soft keyword, place its section before any `const` / `var` / `threadvar` section in the same routine; a preceding one of those would consume the `threadstatic` identifier as a declaration name. A following `var` / `const` is fine. This is the same ordering rule as the `static` section.

A section initializer is still a runtime per-thread assignment (no data-segment fast path, see below), so `expr` may be any expression, not only a compile-time constant. Both forms can be mixed in the same routine.

## Short alias `tstatic`

`tstatic` is a drop-in alias for `threadstatic`. It resolves to the same soft keyword, is gated on the same modeswitch and produces identical code, so it is accepted in every position the long form is.

Inline statement form:

```pas
function NextId: Integer;
begin
  tstatic next := 1000;        // inferred, per-thread counter
  tstatic seen: Boolean;       // explicit type, zero-init per thread
  Result := next;
  Inc(next);
end;
```

Declaration section form:

```pas
function NextId: Integer;
tstatic
  next: Integer = 1000;        // explicit value per thread
  a, b: Integer;               // multi-name, zero-init per thread
begin
  Result := next;
  Inc(next);
end;
```

The two spellings are interchangeable; pick one per routine for readability. A routine may use the section form once (under either spelling), plus any number of inline declarations in the body.

## Per-thread guard, init exactly once per thread

The compiler emits a hidden Boolean guard variable that is itself a threadvar, so each thread has its own guard. The generated logic is:

```pas
if not __guard_per_thread then
begin
  __guard_per_thread := True;       // set BEFORE evaluating the expression
  __var_per_thread := <expr>;
end;
```

- The init expression runs **once per thread**, on the first reach of the declaration in that thread.
- If `<expr>` raises, the exception propagates, the variable keeps its zero bytes, the guard is already true so subsequent calls in that thread skip the init block - no retry for that thread. Other threads still get their own init attempt.
- Other threads continue to evaluate their own init independently.

## Storage and registration

The hidden variable carries `vo_is_thread_var`, so codegen routes loads and stores through the threadvar relocation mechanism and the BSS slot holds a TLS handle. The slot is registered in `FPC_THREADVARTABLES` at unit / program init, the same as a classic top-level `threadvar`.

On win32 / win64 each access does not call `FPC_THREADVAR_RELOCATE`: the fast path is inlined as a read of the running thread's threadvar block from the TEB TLS slot array plus the variable offset, with the helper reached only when the block is not yet allocated for the thread. With the address hoisted out of a loop (which `-O2` does), a threadstatic access then costs the same as a global; the call-per-access form was several times slower.

Debug info splits the location on win32 / win64. `DW_AT_location` stays a plain static address, so a debugger that does not know the per-thread layout (gdb on Windows cannot reach the TEB base) keeps showing the template value without erroring. A vendor attribute, `DW_AT_FPC_threadvar`, carries the real per-thread expression: it reads the running thread's block through the TEB (gs base on win64, fs base on win32) and falls back to the static template when the relocate handler is still nil (single threaded). fpdebug reads that attribute and shows each thread its own value; other debuggers ignore it.

This vendor split is only needed because Windows uses the relocate model. On native-TLS targets (Linux and the other Unix systems) threadvars do not use it at all: the compiler emits the standard `DW_OP_GNU_push_tls_address` location, which gdb resolves out of the box. fpdebug does not yet evaluate that operation, so it cannot show threadvars or threadstatic locals there - but that is a stock fpdebug gap that affects every ordinary `threadvar` just as much, not something this feature introduces.

The sym lives in its declaring routine's local symtable, so `hi` declared in `procedure test` is **not visible** from other routines in the same unit - regular Pascal scoping. To make registration still work, the parser appends every threadstatic sym to `current_module.extra_threadvar_syms`, and `InsertThreadvars` walks that list alongside the standard global / local symtables when building `FPC_THREADVARTABLES`.

The inline form returns the guarded init node straight into the statement stream at the point of declaration. The section form is parsed before the body, so it collects its guarded init nodes on the routine's procinfo and they are spliced to the front of the body, running on entry. Both end up as the same per-thread guarded assignment.

## No const-init fast path

Regular `static` short-circuits a compile-time-constant initializer into the typed-constant data segment - no guard, no BSS, no runtime branch. **Thread-static cannot do that for a non-zero value.** FPC's TLS layout has no per-thread template, so a literal `threadstatic x := 5;` needs the guarded runtime assignment to apply per thread. The cost is one branch on first use per thread - free thereafter.

The one case that does match `static`: an initializer that folds to all-zero bytes (`= 0`, `= nil`, `= false`, `= ''`, empty set). The per-thread block is zero-allocated by the RTL, so the value is already there - the compiler drops the guard and the assignment entirely, exactly as if no initializer were given. A non-zero constant still needs the guard, because the only way to put a non-zero value into a freshly zeroed per-thread block is to run code once per thread.

## Differences from related features

| Feature | Lifetime | Scope | Per | Cost |
|---|---|---|---|---|
| `var x: T;` | call | block | call | stack alloc |
| `threadvar x: T;` (top-level) | program | unit | thread | BSS + TLS relocate |
| `static name := V;` | program | block | program | data segment (const) / BSS + guard (runtime) |
| `threadstatic name := V;` | program | block | thread | TLS + per-thread guard |

## Limitations (current)

- In an anonymous function body the keyword is parsed but the resulting threadvar is not hooked into the closure's capturer machinery (same limitation that anon-static had).
- No TLS template / `.tdata` init: every initializer is runtime, regardless of whether the expression is a compile-time constant.
- Aggregate typed-constant initializers (`array` / `record` literals via `= (...)`) are not supported in either form; the value is read as an expression.
