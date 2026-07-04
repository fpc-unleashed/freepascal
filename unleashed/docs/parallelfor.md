# Parallel For

`for parallel [(N)] var i := lo to|downto hi [step s] [chunk c] do STMT` runs the loop body across a pool of worker threads instead of one after another. The pool is built on `BeginThread`, every iteration is handed out exactly once, and the loop does not return until all of them have finished.

Feature gated by modeswitch `PARALLELFOR`, enabled by default in `{$mode unleashed}`.

## Basic use

```pas
{$mode unleashed}
uses SysUtils;

var total: Integer;
begin
  total := 0;
  for parallel var i := 1 to 1000000 do
    InterlockedExchangeAdd(total, i);     // each i added once, on some worker
end;
```

The body is the same statement you would write in a classic `for`. The difference is that several iterations run at the same time on different threads, so any state shared between iterations has to be touched with an atomic (`InterlockedIncrement`, `InterlockedExchangeAdd`, ...) or under a lock. Writing to a per-iteration local needs nothing - each worker has its own.

## The loop variable is mandatory and inline

The counter must be declared inline with `var`:

```pas
for parallel var i := 1 to N do ...    // ok - each worker owns its copy of i
```

A pre-existing variable is rejected, because a single shared counter cannot be handed to several threads at once:

```pas
var i: Integer;
for parallel i := 1 to N do ...        // error 03432
```

## Pool size

Without a count the pool uses `min(GetCPUCount, iteration_count)` threads. An explicit size goes in parentheses right after `parallel`:

```pas
for parallel(4) var i := 1 to N do ...    // at most 4 workers
for parallel(1) var i := 1 to N do ...    // sequential: caller only, no spawn
```

The count is evaluated once, then clamped to `[1, min(iteration_count, 256)]` - the pool never exceeds 256 threads even when more are asked for, while the atomic dispatch still drains every iteration. `parallel(1)` is the degenerate case: no helper is spawned and the body simply runs on the calling thread, so it is a plain sequential loop.

The calling thread is itself one of the workers - `parallel(N)` spawns `N-1` helpers and then joins the dispatch. The caller does not sit idle waiting.

## Dispatch and ordering

Iterations are handed out dynamically through a shared atomic counter: each worker repeatedly claims the next block of indices (see Chunking below) and computes `i := lo +/- index*step` for each one. Work is balanced automatically when iterations take uneven time, but the order in which bodies run, and which thread runs a given `i`, are **not** defined. Do not rely on iteration order or on a particular thread touching a particular `i`.

`lo`, `hi`, `step`, and `chunk` are each evaluated once before the pool starts, exactly like a classic `for`.

The hidden dispatch state follows the loop variable's width: a 64-bit variable gets a 64-bit counter, so ranges past 2^31 work; smaller types (including enums and chars) stay on the plain 32-bit path. Targets without 64-bit interlocked operations reject a 64-bit loop variable at compile time (error 03436).

## `downto` and `step`

Both compose with the pool the same way they do in a sequential loop:

```pas
for parallel var i := 100 downto 1 do ...           // 100 values, top-down
for parallel var i := 1 to 200 step 2 do ...        // 1,3,5,...,199 - 100 values
for parallel var i := 50 downto 1 step 5 do ...      // 50,45,...,5 - 10 values
```

`step` is positive; use `downto` to descend. (`step` needs `{$modeswitch forstep}`, on by default in `unleashed`.)

## Chunking

Each counter grab claims a block of iterations that the worker then walks without further atomics. That keeps cheap bodies from paying a contended atomic per iteration - one grab covers the whole block. The block size comes from the `chunk` clause, sitting after `step` in the header:

```pas
for parallel var i := 1 to 10000000 chunk 4096 do    // 4096 indices per grab
  arr[i] := 0;

for parallel(4) var i := 1 to N step 2 chunk 100 do  // composes with the rest
  Work(i);
```

Without a clause the size defaults to `count div (workers*4)`, floored at 1 - about four grabs per worker, so a slow chunk still gets rebalanced onto the faster workers while the counter is hit only a handful of times. Pick a large chunk yourself for tiny uniform bodies, a small one for expensive uneven bodies. A runtime chunk value below 1 is clamped to 1; a non-positive constant is a compile error (03438). Like `step`, `chunk` is only a keyword in this one spot - code using `chunk` as an identifier keeps compiling.

## The body reaches enclosing locals

The body is hoisted into a hidden nested routine, so it can read and write the locals of the routine that contains the loop, across the worker threads:

```pas
function CountOdd(n: Integer): Integer;
var c: Integer;
begin
  c := 0;
  for parallel var i := 1 to n do
    if Odd(i) then InterlockedIncrement(c);     // c is CountOdd's local
  CountOdd := c;
end;
```

The shared local lives on the caller's stack frame and the workers reach it through their frame pointer. Because the writes are concurrent, they still need to be atomic or locked.

## Implicit barrier

The loop is a barrier: control passes the `do` body only once every iteration has completed. Anything the bodies wrote is visible afterwards without further synchronization.

## Exceptions

If a body raises, the worker catches it. The first exception caught across all workers (claimed with an atomic flag) is re-raised on the calling thread once the pool has joined; later exceptions on other workers are dropped. So a fault inside a parallel loop surfaces as an ordinary exception at the loop, not as a crash on a helper thread:

```pas
try
  for parallel var i := 1 to N do
    if Bad(i) then raise EMyError.Create('...');
except
  on e: EMyError do HandleIt(e);    // re-raised here, after the barrier
end;
```

## `continue` and `break`; `exit` / `goto` are not allowed

`continue` skips to the next iteration and works as usual.

`break` cancels the loop cooperatively: it raises a shared flag, every worker checks that flag before each iteration, and nothing new starts. Iterations already running on other threads finish normally - across threads there is no way to stop them mid-body - and the loop then joins and continues after `do` as usual. So `break` means "stop handing out work", not "freeze everything this instant":

```pas
for parallel var i := 1 to N do
begin
  if Skip(i) then continue;         // ok - next iteration
  if Found(i) then break;           // ok - no further iterations start
end;
```

With one worker (`parallel(1)`) break is exact, like a sequential loop. A break inside a nested classic loop still binds to that inner loop.

`exit` stays rejected (error 03434): it promises to leave the routine immediately, which a pool that must first join its threads cannot honestly deliver - write `break` and test after the loop instead. `goto` out of the body is rejected too (error 03435). A `for ... in` collection cannot be made parallel either (error 03433); only a numeric range.

## `WorkerIndex` and `WorkerCount`

Inside the body two implicit locals identify the executing worker: `WorkerIndex` (0 to `WorkerCount`-1, claimed once per worker at entry, stable for the whole loop) and `WorkerCount` (the pool size after clamping). They exist for per-worker private state - a scratch buffer or partial sum per worker, indexed without any locking:

```pas
var acc: array[0..3] of Int64;
...
for parallel(4) var i := 1 to N do
  acc[WorkerIndex] := acc[WorkerIndex] + Weight(i);   // slot is private - no atomics
// after the barrier: total := acc[0]+acc[1]+acc[2]+acc[3]
```

Size such arrays with an explicit `parallel(N)` - with a default pool you do not know `WorkerCount` up front. Note `WorkerIndex` says which *worker* is running, not which iteration: one worker executes many different `i`. Both names are locals of the hidden worker routine, so they shadow any outer symbol of the same name only inside the body.

Both are read-only, like the loop variable: assigning to them (or passing them to a `var` parameter, e.g. `Inc(WorkerCount)`) is rejected with "Can't assign values to const variable".

## Nested parallel loops

Each loop spawns its own pool, so by default a `for parallel` whose caller is already a parallel worker runs its body on that worker alone - the inner pool size is forced to 1. The outer loop is parallel, the inner sequential per outer worker. A default inner pool would otherwise give `outer x inner` threads and oversubscribe the cores, which is slower than just parallelizing the outer level.

```pas
for parallel var i := 1 to 4 do
  for parallel var j := 1 to 250 do      // sequential on i's worker
    InterlockedIncrement(total);          // total ends at 1000
```

An explicit pool size on the inner loop is taken as an opt-in to nested parallelism and is kept. Size the inner loop yourself when its work is heavy enough to be worth the extra threads:

```pas
for parallel var i := 1 to 4 do
  for parallel(4) var j := 1 to 250 do   // 4 inner workers per outer worker
    Heavy(i, j);
```

## `parallel` is a context-sensitive keyword

`parallel` is recognized only between `for` and the loop header, and only when the next token is `var` or `(`. Anywhere else it stays an ordinary identifier, so existing code that uses `parallel` as a name keeps working:

```pas
var parallel: Integer;
for parallel := 1 to 5 do ...        // ordinary sequential loop over `parallel`

function parallel: Integer;          // ok - just a function name
```

## Threading driver

The pool uses `BeginThread` / `WaitForThreadTerminate` from the `system` unit. On Windows that works as-is. On Unix the program must pull in a threading driver - put `cthreads` first in the program's `uses` - otherwise thread creation fails at run time, the same requirement any threaded FPC program has. The compiler reminds you once per module with hint 03439 when compiling a parallel loop for a unix-like target. A worker thread that could not be spawned at run time is simply skipped: its share of iterations drains through the workers that did start, worst case the caller alone.

## Errors

| Number | Identifier                            | Trigger                                          |
|--------|---------------------------------------|--------------------------------------------------|
| 03432  | `parser_e_parallel_for_requires_var`  | loop variable is not declared inline with `var`  |
| 03433  | `parser_e_parallel_for_no_for_in`     | `for parallel var x in collection`               |
| 03434  | `parser_e_parallel_for_no_exit`       | `exit` inside the body                           |
| 03435  | `parser_e_parallel_for_no_goto`       | `goto` leaving the body                          |
| 03436  | `parser_e_parallel_for_no_int64_dispatch`  | 64-bit loop variable on a target without 64-bit interlocked ops |
| 03437  | `parser_e_parallel_chunk_not_ordinal`      | `chunk` size is not an ordinal value             |
| 03438  | `parser_e_parallel_chunk_must_be_positive` | constant `chunk` size is zero or negative        |
| 03439  | `parser_h_parallel_for_needs_cthreads`     | hint: parallel loop compiled for a unix-like target |

## Edge cases

| Case                                   | Behavior                                                  |
|----------------------------------------|-----------------------------------------------------------|
| empty range (`1 to 0`)                 | body never runs, no threads spawned                       |
| `parallel(0)` or a negative count      | clamped up to 1 (sequential)                              |
| count larger than the iteration count  | clamped down - never more workers than iterations         |
| count above 256                        | clamped to 256; the atomic counter still covers every index |
| runtime `chunk` below 1                | clamped up to 1                                           |
| full 64-bit range (`low(int64) to high(int64)`) | the iteration count itself overflows - not supported |
| body writes a shared variable plainly  | data race - use an atomic or a lock, the loop only adds the barrier |

## Want it off?

```pas
{$mode unleashed}
{$modeswitch parallelfor-}

for parallel var i := 1 to 10 do ...    // `parallel` is now just an identifier;
                                        // the header no longer parses as parallel
```
