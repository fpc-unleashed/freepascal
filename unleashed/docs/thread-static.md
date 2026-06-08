# Thread-Static Variables

`threadstatic` declares a per-thread variable with program lifetime and block-local source scope. Each thread sees its own copy; init runs once per thread on first reach via a per-thread guard. Two forms, same semantics: an inline statement (`threadstatic name := expr;` anywhere in a body) and a declaration section before the body (parallel to `var` / `static`).

Gated by modeswitch `THREADSTATIC`, enabled by default in `{$mode unleashed}`. Outside unleashed:

```pas
{$mode objfpc}
{$modeswitch threadstatic}
```

Allowed only inside a function / procedure / method body. The token is a soft keyword (not reserved in any mode), so a user identifier called `threadstatic` is not shadowed.

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

The hidden variable carries `vo_is_thread_var`, so codegen routes loads and stores through `FPC_THREADVAR_RELOCATE` and the BSS slot holds a TLS handle. The slot is registered in `FPC_THREADVARTABLES` at unit / program init, the same as a classic top-level `threadvar`.

The sym lives in its declaring routine's local symtable, so `hi` declared in `procedure test` is **not visible** from other routines in the same unit - regular Pascal scoping. To make registration still work, the parser appends every threadstatic sym to `current_module.extra_threadvar_syms`, and `InsertThreadvars` walks that list alongside the standard global / local symtables when building `FPC_THREADVARTABLES`.

The inline form returns the guarded init node straight into the statement stream at the point of declaration. The section form is parsed before the body, so it collects its guarded init nodes on the routine's procinfo and they are spliced to the front of the body, running on entry. Both end up as the same per-thread guarded assignment.

## No const-init fast path

Regular `static` short-circuits a compile-time-constant initializer into the typed-constant data segment - no guard, no BSS, no runtime branch. **Thread-static cannot do that.** FPC's TLS layout has no per-thread template, so even a literal `threadstatic x := 5;` needs the guarded runtime assignment to apply per thread. The cost is one branch on first use per thread - free thereafter.

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
