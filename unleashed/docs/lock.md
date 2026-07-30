# `lock` / `trylock`

Two statements that serialize access across threads, mapped onto FPC's existing `TRTLCriticalSection` and built so the acquire / release pairing can never be forgotten: no declaration, no `InitCriticalSection()` / `DoneCriticalSection()`, and a hidden `try..finally` guarantees the release on every exit path.

Modeswitch: `lock`, enabled by default in `{$mode unleashed}`. Elsewhere:

```pascal
{$mode objfpc}
{$modeswitch lock}
```

`lock` and `trylock` are soft (context-sensitive) keywords: without the modeswitch, existing identifiers with those names keep working. `wait` is never reserved at all - it is recognized only between a lock target list and `do`.

## Grammar

```pascal
lock do <stmt>;                                  // per-callsite hidden lock
lock(v) do <stmt>;                               // per-variable hidden lock
lock(v1, v2, ...) do <stmt>;                     // multi-lock, ordered
lock(myCS) do <stmt>;                            // explicit TRTLCriticalSection

trylock do <stmt> else <stmt>;                   // single attempt
trylock(v) do <stmt> else <stmt>;
trylock(v1, v2, ...) do <stmt> else <stmt>;
trylock(myCS) do <stmt> else <stmt>;
trylock ... wait <int64-expr> do <stmt> else <stmt>;   // bounded wait (ms)
```

The verb split is the whole point: **`lock` blocks until acquired and cannot fail** - no `wait`, no `else`. **`trylock` may miss** - one immediate attempt by default, a bounded wait with `wait N` - **and the `else` branch is mandatory**, spelling out what happens instead of the body. The `else` branch runs *without* the lock held.

| | `wait` | `else` |
|---|---|---|
| `lock` | rejected: `` `lock` cannot take a `wait` clause - use `trylock` for bounded acquisition `` | never consumed |
| `trylock` | optional, default 0 | required: `` `trylock` requires an `else` branch `` |

In both statements the body is wrapped in a hidden `try..finally`, so the lock is released on normal exit, `exit`, `break`, `continue`, `goto`, and propagating exceptions.

## Lock targets

### Per-callsite - bare form

```pascal
lock do inc(gUseCount);
lock do begin
  writeln(logFile, msg);
  Flush(logFile);
end;
```

A hidden `TRTLCriticalSection` is generated per source position and shared by every thread executing exactly that statement. **Two bare statements in different places do NOT share a lock**, even when they touch the same variables. Use the bare form for "only one thread at a time runs *this code*"; use the per-variable form for "only one thread at a time touches *this data*".

### Per-variable - `lock(v)` and `lock(v1, v2, ...)`

The argument names the data being protected. Every `lock(counter)` and `trylock(counter)` in the entire program resolves to the same hidden critical section for `counter`, so the lock is shared across call sites:

```pascal
var counter: integer;

procedure bump; begin lock(counter) do inc(counter); end;
procedure drop; begin lock(counter) do dec(counter); end;
// bump and drop can never run their bodies at the same time
```

With multiple targets the compiler sorts the lock list by each target's dotted source path and emits the enters in that fixed order on every site - `lock(a, b)` here and `lock(b, a)` there both take `a` first, so the AB-vs-BA deadlock pattern cannot happen:

```pascal
lock(accountTo, accountFrom) do begin
  accountFrom.balance -= amount;
  accountTo.balance += amount;
end;
```

Hidden critical sections live in the unit's local symtable, wired into the unit's `initialization` / `finalization` automatically - `InitCriticalSection()` in declaration order at load, `DoneCriticalSection()` in reverse at unload; the implicit init / fini routines are created when the unit had none.

### Explicit critical section

A target of type `TRTLCriticalSection` is used directly - no hidden CS, no auto Init/Done, the user manages the lifetime. This is the escape hatch for cases the auto path does not cover (one CS guarding several variables, coordination with code using the CS directly, per-instance locks):

```pascal
var cacheLock: TRTLCriticalSection;

initialization
  InitCriticalSection(cacheLock);
finalization
  DoneCriticalSection(cacheLock);
end.

// elsewhere
lock(cacheLock) do cache.Add(key, value);
trylock(cacheLock) wait 50 do cache.Add(key, value) else ;
```

The explicit CS may live anywhere an assignable location can: a global, a class var, a local, a `var` parameter, an instance field (`lock(cs) do ...` in a method then serializes per instance), or behind a pointer (`lock(p^)`). For field and pointer targets the address is evaluated once, before the first acquisition attempt, so mutating the pointer inside the body cannot unbalance the release.

## `trylock` semantics

```pascal
trylock(v) do inc(v) else handleBusy;
trylock(a, b) wait 100 do transfer else giveUp;
trylock(logCS) do Flush(logFile) else ;     // explicit "skip if busy"
trylock wait 200 do <stmt> else <stmt>;     // callsite form
```

The `wait` budget is a signed 64-bit count of **milliseconds**, evaluated exactly once before the first attempt - any integer expression fits. A negative constant reports `` `wait` value must be non-negative ``; a negative runtime value behaves like `0`.

- **No `wait`, or `wait 0`** - one immediate `TryEnterCriticalSection()` plus a few `ThreadSwitch()` yields (locks held for microseconds are usually caught here), then `else`. No sleeping.
- **`wait N > 0`** - the above, then 16 ms sleep slices until acquired or the budget is spent. The slice floor matches the default Windows timer resolution (~15.6 ms), so summing slept slices is an honest elapsed-time estimate without reading any clock; the practical contract is "at least N ms of attempts, gives up within roughly N + one tick". Sub-tick budgets round up to one tick on Windows.

The sleeping uses `RTLEventWaitFor()` on a throwaway, never-signaled RTL event - a portable timed sleep from the `system` unit, so `trylock` adds **no dependency on SysUtils** and the uncontended fast path allocates nothing.

**Multi-lock `trylock` is all-or-nothing**: the locks are tried in the usual sorted order with `TryEnterCriticalSection()`; on the first failure the ones already taken are released in reverse, the thread sleeps a slice, and the whole sequence retries. A partial grab never survives into either branch, so a `trylock` site cannot deadlock against a blocking `lock(a, b)` site.

### `else` pairing

Enforced both ways: `trylock` without `else` is a compile error, and `lock` never consumes an `else` (one appearing after its body binds to an enclosing `if`, as usual). When a `trylock` body is itself an `if` without its own `else`, the `if` would swallow the branch - wrap the body in `begin..end` so the `else` binds to the `trylock`.

## Restrictions

- Every target must be an **assignable location**; expressions, calls, and literals report `` `lock` argument must be a variable reference ``.
- Auto targets (non-CS type) must be **globals** (unit-level or main-program `var`) or **class vars**. A routine-local variable or parameter reports `` `lock` auto-locking only supports global variables and class vars - for locals pass an explicit `TRTLCriticalSection` `` - the hidden CS lives in unit init / fini, which has no per-call instance.
- Auto-locking on an instance field reports `` `lock` cannot auto-lock on a field - use an explicit `TRTLCriticalSection`, a global, or a class var `` - the hidden CS is keyed by symbol, not by instance, so all instances would share one lock. For per-instance locking give the object a `TRTLCriticalSection` field and lock on that.
- There is no warning when the body touches shared state that is *not* named in the target list - the target names the lock, the granularity stays your call.

## Re-entrancy

The critical section is recursive on every supported target (Windows `EnterCriticalSection()` by API contract, FPC's `cthreads` initializes `pthread_mutex` as `PTHREAD_MUTEX_RECURSIVE`). One thread can nest `lock(v)` on the same target without self-deadlock, and a nested `trylock(v)` on a lock the thread already holds succeeds immediately:

```pascal
procedure inner; begin lock(g) do inc(g); end;
procedure outer;
begin
  lock(g) do begin
    inc(g);
    inner; // re-enters the same CS, fine
  end;
end;
```

## Lowering

A `lock` site lowers to:

```pascal
EnterCriticalSection(lock1);
EnterCriticalSection(lock2); // only with multiple targets
try
  <body>;
finally
  LeaveCriticalSection(lock2);
  LeaveCriticalSection(lock1);
end;
```

A `trylock` site lowers to the same shape behind an acquisition loop:

```pascal
acquired := false;
remaining := <wait>;               // evaluated once
<try-all attempt>;                 // TryEnter each lock, roll back on failure
<3 x ThreadSwitch + retry>;
if (not acquired) and (remaining > 0) then begin
  ev := RTLEventCreate;
  while (not acquired) and (remaining > 0) do begin
    RTLEventWaitFor(ev, slice);    // 16 ms slices
    dec(remaining, slice);
    <try-all attempt>;
  end;
  RTLEventDestroy(ev);
end;
if acquired then
  try <body> finally <leaves> end
else
  <else-branch>;
```

A constant `wait 0` (or an absent clause) folds the sleep machinery away at parse time. Everything is built as a regular Pascal AST and handed to the standard type-check and codegen passes, so `exit`-from-body unwind, exception unwind, `break` / `continue` from a surrounding loop, nesting, and debugger stepping behave as for hand-written code.

## Implementation notes

- `lock` / `trylock` are tokens registered as keywords only while `m_lock` is active; outside it the scanner emits plain identifiers.
- Hidden critical sections are static syms in the module's local symtable, named `$lock_cs_<line>_<col>` (per-callsite) and `$lock_var_<varname>` (per-variable).
- After the unit's `initialization` / `finalization` are parsed, the collected lock syms get `InitCriticalSection()` calls prepended to the init body and `DoneCriticalSection()` calls appended (in reverse) to the fini body, force-creating the implicit init / fini routines when absent.
- The hooks add no overhead to programs that use neither statement.

## Demo

```pascal
program lock_demo;

{$mode unleashed}

var
  total: integer;
  gate: integer;
  held, release: boolean;

begin
  // 200000 increments across all cores - the lock makes read-modify-write atomic
  total := 0;
  for parallel var i := 1 to 200000 do
    lock(total) do inc(total);
  writeln($'total = {total} (exact, no lost updates)');

  // deterministic trylock: a worker holds the lock until told to let go
  var w := async begin
    lock(gate) do begin
      held := true;
      while not release do ThreadSwitch;
    end;
  end;
  while not held do ThreadSwitch;

  trylock(gate) do writeln('unexpected') else writeln('busy - else runs without the lock');
  release := true;
  trylock(gate) wait 2000 do writeln('acquired after the worker released') else writeln('timed out');
  await w;
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
total = 200000 (exact, no lost updates)
busy - else runs without the lock
acquired after the worker released
```
