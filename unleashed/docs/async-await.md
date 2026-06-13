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

A fire-and-forget future is never awaited, so its exception is never read: it is swallowed when the future is finalized, not propagated. If a worker may fail and the failure matters, keep the future and `await` it.

## Compile-time checks

```pas
writeln('z = ', z);   // error: future value used without `await`
await x;               // error if x is not a future
async (a + b);         // error: `async` needs a routine call or a block
```

Outside the modeswitch, `async`, `await`, and `future` are ordinary identifiers and none of the above is recognized.

## Notes

- **Threads must be available.** On Unix you need a threading driver, so add `cthreads` as the first unit of the program; on Windows threading is available out of the box.
- **Shared mutable state is your responsibility.** The call form snapshots arguments by value, but the block form captures by reference and a snapshotted `self` shares the object. Mutating a captured variable (or an object's fields) from the spawning thread after `async` while the worker reads it is a data race - synchronize it yourself.
- **Fire-and-forget side effects may not finish.** When the program exits, outstanding fire-and-forget workers are not awaited; their remaining side effects may or may not have run. Keep and `await` the future when you need the work to complete.
