# Lock - `lock`, `trylock`

Two statements that serialize access across threads, mapped onto FPC's existing `TRTLCriticalSection` and built so the acquire/release pairing can never be forgotten. Inspired by C# `lock`, Java `synchronized`, and the `lock` / `try_lock` verb split that POSIX, C++, Java, and Rust all converged on.

Feature gated by modeswitch `LOCK`, enabled by default in `{$mode unleashed}`.

```pas
{$mode objfpc}
{$modeswitch lock}
```

`lock` and `trylock` are soft (context-sensitive) keywords: outside the modeswitch any existing identifiers with those names continue to work. `wait` is never reserved at all - it is recognized only between a lock target list and `do`.

## Grammar

```pas
lock do <stmt>;                                  // per-callsite hidden lock
lock(v) do <stmt>;                               // per-variable hidden lock
lock(v1, v2, ...) do <stmt>;                     // multi-lock, ordered
lock(MyCS) do <stmt>;                            // explicit TRTLCriticalSection

trylock do <stmt> else <stmt>;                   // single attempt
trylock(v) do <stmt> else <stmt>;
trylock(v1, v2, ...) do <stmt> else <stmt>;
trylock(MyCS) do <stmt> else <stmt>;
trylock ... wait <int64-expr> do <stmt> else <stmt>;   // bounded wait (ms)
```

The split is the whole point: **`lock` blocks until acquired and cannot fail** - no `wait`, no `else`. **`trylock` may miss** - one immediate attempt by default, a bounded wait with `wait N` - **and the `else` branch is mandatory**, spelling out what happens instead of the body. The branch runs *without* the lock held.

| | `wait` | `else` |
|---|---|---|
| `lock` | rejected (`use trylock`) | never consumed |
| `trylock` | optional, default 0 | required |

In both statements the body is wrapped with a `try ... finally`, so the lock is released on normal exit, `exit`, `break`, `continue`, `goto`, or a propagating exception.

## Lock targets

### Per-callsite - bare form

```pas
lock do Inc(GUseCount);
lock do begin
  WriteLn(LogFile, msg);
  Flush(LogFile);
end;
```

A hidden `TRTLCriticalSection` is generated per source position and reused by every thread executing exactly that statement. **Two bare statements in different places do NOT share a lock** even if they touch the same variables. Use the bare form when "only one thread at a time on *this* sequence of instructions" is what you want; use the per-variable form when "only one thread at a time touches *this data*" is.

### Per-variable - `lock(v)` and `lock(v1, v2, ...)`

The argument names the data being protected. Every `lock(counter)` and `trylock(counter)` in the entire program resolves to the same hidden `TRTLCriticalSection` for `counter`, so the lock is shared across call sites:

```pas
var
  counter: Integer;

procedure Bump; begin lock(counter) do Inc(counter); end;
procedure Bump2; begin lock(counter) do Dec(counter); end;
// Bump and Bump2 cannot run their bodies at the same time
```

With multiple targets the compiler sorts the lock list by symbol name and emits enters in that fixed order on every site. So `lock(a, b)` at one place and `lock(b, a)` at another both take the locks in the same order (`a` then `b`), making the AB-vs-BA deadlock pattern impossible:

```pas
lock(account_to, account_from) do begin
  account_from.Balance := account_from.Balance - amount;
  account_to.Balance   := account_to.Balance + amount;
end;
```

Hidden critical sections live in the unit's local symtable. The compiler wires them into the unit's `initialization` / `finalization` sections - `InitCriticalSection` runs in declaration order at unit load, `DoneCriticalSection` in reverse at unit unload. When a unit had no `initialization` / `finalization` of its own, an implicit init/fini routine is created.

### Explicit critical section

If a target's type is `TRTLCriticalSection`, the compiler treats it as a user-managed lock - the variable is used directly, no hidden CS is created, no auto Init/Done is emitted. This is the escape hatch for any case the auto path does not cover (sharing a single CS across multiple variables, coordinating with code that uses the CS directly):

```pas
var
  CacheLock: TRTLCriticalSection;

initialization
  InitCriticalSection(CacheLock);
finalization
  DoneCriticalSection(CacheLock);
end.

// elsewhere
lock(CacheLock) do Cache.Add(key, value);
trylock(CacheLock) wait 50 do Cache.Add(key, value) else ;
```

The explicit CS may be a global, a class var, a local variable, a `var` parameter, an instance field, or a dereferenced pointer (`lock(p^)`) - the compiler does not constrain its storage class because the user is on the hook for the lifetime. An instance field CS serializes per instance: `lock(cs) do ...` inside a method of a class with `cs: TRTLCriticalSection` locks only that object. For field and pointer targets the address is evaluated once, before the first acquisition attempt, so mutating the pointer inside the body cannot unbalance the release.

## `trylock` semantics

```pas
trylock(v) do Inc(v) else HandleBusy;
trylock(a, b) wait 100 do Transfer else GiveUp;
trylock(LogCS) do Flush(LogFile) else ;     // explicit "skip if busy"
trylock wait 200 do <stmt> else <stmt>;     // callsite form
```

The `wait` budget is a signed 64-bit count of **milliseconds**, evaluated exactly once before the first attempt - any integer expression fits (`Integer`, `Cardinal`, `Int64`, computed values). A negative constant is a compile error; a negative runtime value behaves like `0`.

- **No `wait`, or `wait 0`** - one immediate `TryEnterCriticalSection` plus a few `ThreadSwitch` yields (locks held for microseconds are usually caught here), then `else`. No sleeping.
- **`wait N > 0`** - the above, then 16 ms sleep slices until acquired or the budget is spent. The slice floor matches the default Windows timer resolution (~15.6 ms), so summing slept slices is an honest elapsed-time estimate without reading any clock; the practical contract is "at least N ms of attempts, gives up within roughly N + one tick". Sub-tick budgets round up to one tick on Windows.

The sleeping is done with `RTLEventWaitFor(ev, slice)` on a throwaway, never-signalled RTL event - a portable timed sleep from the `system` unit, so `trylock` adds **no dependency on SysUtils**. The event is created on demand in the contended path and destroyed right after, which keeps it contract-clean (one waiter per event) and means the uncontended fast path allocates nothing.

**Multi-lock `trylock` is all-or-nothing**: the locks are tried in the usual sorted order with `TryEnterCriticalSection`; on the first failure the ones already taken are released in reverse, the thread sleeps a slice, and the whole sequence is retried (the classic try-and-back-off dance, same as C++ `std::try_lock`). A partial grab never survives into either branch, so a `trylock` site cannot deadlock against a blocking `lock(a, b)` site.

### `else` pairing

The pairing is enforced both ways. `trylock` without `else` is a compile error - a missed acquisition would silently skip the body otherwise. `lock` never consumes an `else`; one appearing after its body binds to an enclosing `if`, as usual. When a `trylock` body is itself an `if` without its own `else`, the `if` swallows the `else` and the `trylock` reports the missing branch - wrap the body in `begin..end`.

Inside the target list and the `wait` clause the bare names are taken contextually: a variable literally named `wait` cannot follow the target list unqualified (nothing else is legal in that position, so it always reads as the clause).

## Restrictions

- Every `lock(...)` / `trylock(...)` target must be an **assignable location**: a variable, or for an explicit `TRTLCriticalSection` also an instance field or a dereferenced pointer. Expressions, function calls, and literals are rejected (`E_lock argument must be a variable reference`).
- For the auto path (non-CS type), the target must be a **global** (unit `var`) or a **class var**. Local variables and parameters are rejected because the hidden CS lives in the unit's init/fini, which has no per-call instance to wire to (`E_lock auto-locking only supports global variables and class vars`).
- **Auto-locking on a field** (`lock(self.field)` with a non-CS field) is rejected - the hidden CS is keyed by the target symbol, not by the instance, so all instances would share one lock (`E_lock cannot auto-lock on a field`). For per-instance locking give the object an explicit `TRTLCriticalSection` field and lock on that; otherwise promote the target to a `class var` or a global.
- There is no warning when the body modifies a global that is **not** named in the target list - the compiler trusts the programmer to pick the right lock granularity.

## Re-entrancy

On every supported target the hidden critical section is recursive (Windows `EnterCriticalSection` is recursive by API contract, POSIX `pthread_mutex` is initialised with `PTHREAD_MUTEX_RECURSIVE` in FPC's `cthreads`). So one thread can enter the same `lock(v)` nested without deadlocking itself, and a nested `trylock(v)` on a lock the same thread already holds succeeds immediately:

```pas
procedure Inner; begin lock(g) do Inc(g); end;
procedure Outer;
begin
  lock(g) do begin
    Inc(g);
    Inner;  // re-enters the same CS, OK
  end;
end;
```

## Lowering

A `lock` site lowers to:

```pas
EnterCriticalSection(lock_1);
EnterCriticalSection(lock_2);   // only with multiple targets
...
try
  <body>;
finally
  LeaveCriticalSection(lock_N);
  ...
  LeaveCriticalSection(lock_1);
end;
```

A `trylock` site lowers to the same shape behind an acquisition loop:

```pas
acquired := false;
remaining := <wait>;               // only with a wait clause; evaluated once
<try-all attempt>;                 // TryEnter each lock, roll back on failure
<3 x ThreadSwitch + retry>;
if (not acquired) and (remaining > 0) then
begin
  ev := RTLEventCreate;
  while (not acquired) and (remaining > 0) do
  begin
    RTLEventWaitFor(ev, min(16, remaining));
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

A constant `wait 0` (or an absent clause) folds the whole sleep machinery away at parse time. Everything is built as a Pascal AST and handed to the regular type-check and code generation passes - the same passes that compile a hand-written `try..finally` - so `exit`-from-body unwind, exception unwind, `break`/`continue` from a surrounding loop, nesting, and debugger stepping all work as for ordinary code.

## Implementation notes

- `lock` / `trylock` are tokens (`_LOCK`, `_TRYLOCK` in `compiler/tokens.pas`) registered as keywords only when `m_lock` is in `current_settings.modeswitches`. Outside that, the scanner emits them as regular identifiers.
- Hidden critical sections are `tstaticvarsym` instances created in `current_module.localsymtable`, registered for emission via `cnodeutils.insertbssdata`, and added to the `tmodule.lock_cs_syms` list. The naming scheme is `$lock_cs_<line>_<col>` (per-callsite) and `$lock_var_<varname>` (per-variable).
- `emit_lock_initdone` in `compiler/pmodules.pas` walks `lock_cs_syms` after the unit's `initialization` / `finalization` sections are read, prepending `InitCriticalSection` calls to the init body and appending `DoneCriticalSection` calls (in reverse) to the fini body. It force-creates implicit init/fini procinfos if needed so the lock lifetime is always tied to the unit's load / unload.
- The implementation lives in `compiler/pstatmnt.pas` (parser + tree gen) and `compiler/pmodules.pas` (init/fini wiring). The hooks add no overhead to programs that use neither statement.
