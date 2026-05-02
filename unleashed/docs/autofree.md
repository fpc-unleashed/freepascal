# Scoped Cleanup - `defer`, `autofree`, scoped `with`

Scope-based resource management without the `try..finally` boilerplate. Inspired by Go's `defer`, C#'s `using`, and Rust RAII, all built on top of Pascal's existing `try..finally` and integrated with the `with` statement.

Feature gated by modeswitch `AUTOFREE`, enabled by default in `{$mode unleashed}`.

```pas
{$mode objfpc}
{$modeswitch autofree}
```

Two new keywords are reserved when the modeswitch is active:

- `defer STATEMENT;` - register a statement to fire at scope exit
- `autofree EXPR` - prefix on a class instance, triggers `Free` at scope exit

Plus a small extension to `with`: it now accepts an inline-var binding (with optional `autofree`) or assignment to an existing local.

## `defer`

Register an arbitrary statement to run when the enclosing block exits. Multiple defers fire in **LIFO** order. The deferred body is evaluated *at exit time*, not at the point of registration (this is **opposite to Go**), so it sees the variable's last value.

```pas
procedure foo;
begin
  Lock.Enter;
  defer Lock.Leave;        // released no matter how foo exits

  AssignFile(F, 'x.txt');
  Reset(F);
  defer CloseFile(F);

  // ... work ...
end;
```

### Scope

The scope of a `defer` is the **enclosing `begin..end` block** (or the body of a `with` statement - see below). Defers fire when the block finishes by:

- normal end of the block
- `exit` / `exit(value)` - `Result` is computed first, then defers, then the actual return
- `break` / `continue` (the loop body's defers run before jumping)
- `goto` out of the block
- an exception propagating out of the block

Defers do **not** fire on `Halt`, `RunError`, or process termination by signal - those bypass the standard `try..finally` machinery.

### LIFO order

```pas
begin
  defer Writeln('A');   // 3rd
  defer Writeln('B');   // 2nd
  defer Writeln('C');   // 1st
  Writeln('body');
end;
// output: body, C, B, A
```

### Conditional registration

Only the defers whose registration site is reached actually fire. If a `raise` happens between two defers, only the first one runs:

```pas
begin
  defer Writeln('first defer');
  DoSomething;
  raise EBoom.Create('!');     // -> only 'first defer' fires
  defer Writeln('second defer'); // never registered
end;
```

### Per-iteration scope in loops

The scope is `begin..end`, not the routine. To get per-iteration cleanup, use an explicit block in the loop body:

```pas
for i := 1 to 3 do
begin
  defer Writeln('iter ', i, ' end');   // fires every iteration
  Writeln('iter ', i);
end;
// output: iter 1 / iter 1 end / iter 2 / iter 2 end / iter 3 / iter 3 end
```

A bare `for ... do defer Foo;` (no `begin..end`) registers the defer in the enclosing block, so it fires once at the end of *that* outer block, not once per iteration.

### Evaluation timing

Argument expressions in the deferred call are evaluated at exit, not at registration:

```pas
var v := 1;
defer Writeln('v = ', v);
v := 2;
v := 3;
// output: v = 3
```

If you need a snapshot, capture into a local:

```pas
var snapshot := v;
defer Writeln('snapshot = ', snapshot);
```

### Forbidden contexts

- `defer defer X;` - a `defer` cannot itself be a deferred statement (`parser_e_defer_inside_defer`).
- Inside an `asm..end` block.
- In a routine where implicit exceptions are disabled (`{$IMPLICITEXCEPTIONS OFF}`) - defer needs a `try..finally`.

## `autofree`

Sugar that registers a `Free` defer for a class instance you just allocated. The cleanup uses a nil-guarded pattern (`if x<>nil then begin x.Free; x:=nil end`), so a manual `x.Free; x := nil;` earlier in the same scope makes the auto-cleanup a no-op rather than crashing on a double-free.

The right-hand side must produce an instance of a class derived from `TObject`.

### Inline-var form

```pas
begin
  var x := autofree TStringList.Create;
  x.Add('hello');
end;
// x.Free called here automatically
```

### Classic-var form

`autofree` also works on the right-hand side of an assignment to an existing local variable:

```pas
var
  x: TStringList;
begin
  x := autofree TStringList.Create;
  x.Add('hello');
end;
// x.Free called here
```

Multiple autofrees in the same scope free in LIFO order:

```pas
begin
  var a := autofree TFoo.Create;
  var b := autofree TBar.Create;
  // ...
end;
// b.Free first, then a.Free
```

### Constructor that raises

If the constructor raises, the auto-Free does *not* fire on the half-built or never-built instance. FPC's normal "automatic destroy on constructor failure" still runs, so each successful `Create` is matched by exactly one `Destroy`:

```pas
var a := autofree TMaybeFails.Create(false);  // ok
var b := autofree TMaybeFails.Create(true);   // raises
// a is freed by autofree
// b is destroyed by FPC's auto-destroy-on-failed-constructor
// no double-Free
```

### Restrictions

- The expression's type must inherit from `TObject` and have a reachable `Free` method (`parser_e_autofree_requires_class`).
- For the classic-var form, the LHS must be a plain variable load (`parser_e_autofree_lhs_must_be_local`). Class fields, globals, array elements and dereferences are rejected - the cleanup is scoped to the routine, so freeing something whose lifetime exceeds the routine would be wrong.
- Currently not allowed as a function call argument (`Foo(autofree T.Create)` - assign to a local first).

## Scoped `with`

The `with` statement gets three new clause forms under `AUTOFREE`. They all bind a class instance to a name (or a hidden holder) that the `with` body sees in scope, with optional auto-cleanup.

### Form C: inline-var with optional autofree

```pas
with var http := autofree TFPHTTPClient.Create(nil) do
  s := http.Get('http://httpbin.org/ip');
// http.Free called here
```

The variable is declared in the enclosing routine's local scope. `autofree` is optional - without it, you manage the lifetime yourself:

```pas
with var http := TFPHTTPClient.Create(nil) do
begin
  defer http.Free;
  s := http.Get('http://httpbin.org/ip');
end;
```

### Form B: bind to an existing local

If the holder is already declared, just assign:

```pas
var http: TFPHTTPClient;
with http := autofree TFPHTTPClient.Create(nil) do
  s := http.Get('http://httpbin.org/ip');
```

### Form A: hidden holder

If you don't need a name (the with-body reaches the methods directly), omit the `:=` entirely:

```pas
with autofree TFPHTTPClient.Create(nil) do
  s := Get('http://httpbin.org/ip');
```

The compiler synthesizes a hidden local for cleanup tracking. The body accesses methods through the with-symtable as usual.

### Multi-with combinations

Each entry can pick its own form, including a mix of autofree and not:

```pas
with var a := autofree TFoo.Create,
     var b := autofree TBar.Create,
     existing_c do
begin
  Use(a, b, existing_c);
end;
// LIFO: b.Free first, then a.Free
```

### Defer inside the with body

A `defer` written inside the body of a scoped `with` (any of the three forms) is scoped to *that* `with`, not the enclosing routine, and fires before the autofree cleanup:

```pas
with var t := autofree T.Create do
begin
  defer Writeln('user defer');
  Writeln('body');
end;
// output: body, user defer, [t.Free]
```

This works even with single-statement bodies (no `begin..end`):

```pas
with var t := autofree T.Create do
  defer DoCleanup;
// output: [DoCleanup], [t.Free]
```

A classic `with X do BODY` (no inline-var, no autofree) is unchanged - defers in its body still attach to the enclosing routine, just as before.

### Classic with is unaffected

`with foo do ...`, `with foo.bar do ...`, `with foo, bar do ...` without `var`/`autofree`/`name :=` keep their stock semantics identically. The new forms are additive.

## Lowering

`defer X;` registers an entry in a per-block list. At the end of the block the parser injects a `try..finally` that runs the registered entries in reverse order, gated on per-defer boolean flags so that only defers whose registration point was reached actually fire. The flags are zero-initialized at block entry.

`autofree EXPR` desugars to a transparent helper block with two statements: the assignment, and a registered `defer if x<>nil then begin x.Free; x:=nil end`. The helper block is flagged `bnf_defer_transparent` so the enclosing block's defer-rewrite walks into it and groups the cleanup with any user defers nearby.

A scoped `with` adds the holder variable, runs `rewrite_defers_in_block` over the body to capture any user defers under the with-scope, and - when `autofree` is present - wraps the resulting body in a direct `try..finally` for the holder cleanup. So a body with both yields:

```
try
  try
    BODY                       // user code
  finally
    if user_defer_flag then DEFER_BODY   // user defers (LIFO)
  end
finally
  if x <> nil then begin x.Free; x := nil end   // autofree cleanup
end
```

The auto-cleanup is the outer frame, so it fires after any user defers in the body.

## Limitations

- `autofree` not yet allowed as a call argument (`Foo(autofree T.Create)`).
- No detection of `var x := autofree existing.Create` where `existing` is an instance (re-init) rather than a type. The compiler accepts it and the runtime would `Free` an instance whose lifetime is not owned by the scope. Don't do that.
- `defer x.Free` written manually next to `autofree x` does not warn; the nil-guard makes the second `Free` a no-op, so it's a redundant write of `nil` to `x` at scope exit, not a crash.
