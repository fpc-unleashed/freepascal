# Async / Await - thread futures

`async` runs an expression or a block on a fresh worker thread and hands back a future; `await` blocks until that thread finishes and reads its result. This is the `std::async` model from C++, **not** the `async`/`await` of C#: there is no function coloring, no event loop, no scheduler. An `async` is one thread, an `await` is one join.

Feature gated by modeswitch `ASYNCAWAIT`, enabled by default in `{$mode unleashed}`.

## The `future of T` type

`async` yields a `future of T` when the work produces a value of type `T`, or a bare `future` when the work produces nothing:

```pas
var z: future of string := async fetchName;   // explicit type
var z := async fetchName;                      // inferred: future of string
var w: future := async doWork;                 // bare future, no value
```

A future is an opaque handle to a pending result. It is a reference-counted interface, so it can be stored in a variable, returned from a function, or passed as a parameter, and it stays alive as long as anything (including the running worker) holds it.

```pas
function startFetch: future of string;
begin
  result := async fetchName;     // the future outlives this function
end;
```

## `async` - spawn the work

There are two forms.

**Call form** `async <routine call>` evaluates the call's arguments **now**, on the spawning thread, snapshots them by value, and runs the routine on the worker from those snapshots:

```pas
var a := 2;
var sum := async add(a, 3);      // a is read here, as 2
a := 100;                        // does not affect sum
writeln(await sum);              // 5
```

For a method call the `self` reference is snapshotted the same way (so the object identity is fixed), but the object's fields are shared state - mutate them on another thread at your own risk.

**Block form** `async begin ... end` runs the block on the worker and yields a bare `future`. The block captures referenced locals **by reference** through the function-reference machinery, on the heap with reference counting, so the future may safely outlive the routine that spawned it and the worker sees later mutations:

```pas
counter := 0;
var w := async begin
  counter := counter + 41;
end;
await w;
writeln(counter + 1);            // 42
```

Inside a method the block has the method's full class context, like an anonymous function: `Self` and strict private members (including auto-property backing fields) resolve as usual.

A bare expression with neither a call nor a block (`async (a + b)`) is a syntax error - wrap it in a routine.

## `await` - join and read

`await f` blocks the current thread until `f`'s worker finishes. For a `future of T` it is an expression of type `T`; for a bare `future` it is a statement:

```pas
writeln(await z);                // string
await w;                         // statement, just joins
```

`await` binds like a unary operator (tighter than binary operators), so `await x + 1` means `(await x) + 1`.

Joining is repeatable. The event behind a future is re-armed after each `await`, and the result is held in the future, so multiple `await` on the same future all succeed and only the first one actually waits:

```pas
var n := await sum + 1;          // does not wait again, reads the cached 5
```

## Controlling the worker

Beyond `await`, the future carries a small control surface. Everything except `Cancel` is read-only; assigning to any of these is a compile error:

```pas
var h := async crunch(data);

h.Cancel;             // raise the cooperative cancel flag
writeln(h.Cancelled); // boolean: was Cancel called on this future
writeln(h.Done);      // boolean: has the worker finished (never blocks)
writeln(h.ThreadID);  // TThreadID: the worker's BeginThread id
```

`Done` is published by the worker right before it releases any awaiter, so a poll loop can track progress without blocking, and once `Done` is true an `await` returns immediately:

```pas
while not h.Done do begin
  UpdateProgress;
  Sleep(10);
end;
writeln(await h);     // the result is already in, this does not wait
```

## Cooperative cancellation

`Cancel` kills nothing. It raises a flag that the work is expected to poll and honor. Inside `async begin ... end` the flag is visible as a read-only boolean named `Cancelled`, the same way `WorkerIndex` is visible in a `for parallel` body:

```pas
var h := async begin
  while not Cancelled do
    DoChunk;
end;
// later, from the spawning side:
h.Cancel;             // ask the worker to stop
await h;              // returns once the loop notices the flag
```

Each nested `async begin` sees its own `Cancelled`, the one of the future it runs under. The call form runs an ordinary routine which cannot see the flag; a routine that must be cancellable takes its own flag as an argument (`Cancel`/`Cancelled` on the handle still work, as caller-side bookkeeping).

## `ThreadID` and the RTL thread API

`ThreadID` returns the value `BeginThread` handed back, which is exactly the currency of the RTL thread API: `ThreadSetPriority`, `WaitForThreadTerminate(h.ThreadID, 100)` and, if you accept the consequences, `KillThread(h.ThreadID)`.

`KillThread` is a last resort. The thread dies without unwinding: no `finally` runs, everything it allocated leaks, and if it held a lock (the heap manager's, for instance) the whole process may deadlock later. The future's machinery is not compensated either: a killed worker never signals completion, so `Done` stays false, a later `await` blocks forever, and the future object itself is never freed (the worker's self-reference is never released). Prefer `Cancel` plus a polling worker.

## Fire and forget

Spawn without keeping the future and the work still runs - the worker holds the only reference, and the future object frees itself once the thread is done:

```pas
async logToFile('done');         // runs on a worker, nobody waits
async begin
  Sleep(300);
  Flush;
end;
```

A statement intrinsic such as `async writeln(...)` runs verbatim on the worker. Its operands are evaluated there, so it cannot read a local of the spawning routine; doing so is a compile error directing you to the block form, which captures:

```pas
async writeln('hello');          // ok - literal
// async writeln(localVar);      // error: wrap in `async begin writeln(localVar) end`
```

## Exceptions

An exception raised on the worker is captured and **re-raised on the caller at the first `await`**:

```pas
var bad := async begin
  raise Exception.Create('boom');
end;
try
  await bad;
except
  on E: Exception do writeln(E.Message);   // boom
end;
```

A fire-and-forget future is never awaited, so its exception is never read: it is swallowed (and freed) when the future is finalized, not propagated. If a worker may fail and the failure matters, keep the future and `await` it.

The exception is delivered exactly once: after the first `await` re-raises it, a subsequent `await` on the same future does not raise again and yields the result field's default (zeroed) value.

## Targets of the call form

The call form accepts an ordinary routine, a method of any visibility including strict private (the `self` reference is snapshotted like an argument), an overloaded routine, a generic specialization (`async TwoOf<Integer>(21)`), and a call through a procedural variable (`async pv()` - the procvar value is snapshotted, later reassignment does not affect the spawned work).

Not accepted, with dedicated errors:

- **`var`/`out` arguments** - the by-value snapshot would silently drop the worker's writes to the caller's variable. Use the block form or return the value through the future.
- **Nested routines** - they reach the parent's locals through the enclosing stack frame, which the worker outlives. Move the work to a top-level routine.

For `await` the operand binds like a unary operator, so a direct generic call needs parentheses: `await (GetAsync<T>(x))`.

## Compile-time checks

```pas
writeln('z = ', z);   // error: future value used without `await`
await x;               // error if x is not a future
async (a + b);         // error: `async` needs a routine call or a block
async bump(n);         // error if bump takes n by var/out
async inner;           // error if inner is a nested routine
```

Outside the modeswitch, `async`, `await`, and `future` are ordinary identifiers and none of the above is recognized.

## Notes

- **Threads must be available.** On Unix you need a threading driver, so add `cthreads` as the first unit of the program; on Windows threading is available out of the box.
- **Shared mutable state is your responsibility.** The call form snapshots arguments by value, but the block form captures by reference and a snapshotted `self` shares the object. Mutating a captured variable (or an object's fields) from the spawning thread after `async` while the worker reads it is a data race - synchronize it yourself.
- **Fire-and-forget side effects may not finish.** When the program exits, outstanding fire-and-forget workers are not awaited; their remaining side effects may or may not have run. Keep and `await` the future when you need the work to complete.
- **`future of T` is one type everywhere.** Each module interns its own synthesized interface, but two futures with the same element type compare as the same type, so futures cross unit boundaries freely.
- **Cleanup is automatic.** When the last reference to a future drops, a synthesized destructor releases the RTL event, the thread handle, and a still-unread worker exception.
