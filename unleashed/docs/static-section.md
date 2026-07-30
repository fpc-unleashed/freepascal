# Static Variables

Declare variables with **program-wide lifetime** but **block-local scope** - the C `static int x;` inside a function. Use them wherever you would otherwise promote a local to a unit-level global just to make it survive calls: counters, one-time init, caches. Two flavors:

- **Section static** (modeswitch `staticsection`): a `static` declaration block at the top of a body, compile-time initializers, zero runtime cost.
- **Inline static** (modeswitch `inlinestatic`): `static name := expr;` anywhere in a body, runtime initializers, evaluated once on first reach.

Both are enabled by default in `{$mode unleashed}`. Elsewhere:

```pascal
{$mode objfpc}
{$modeswitch staticsection}
{$modeswitch inlinestatic}
```

Both are allowed **only inside function / procedure / method bodies**; at unit / program level plain `var` already gives program lifetime, and `static` there reports `static is only allowed in function/procedure bodies`.

Static variables are **not** thread-local - all threads share one instance. Provide your own locking / atomics, or use [`threadstatic`](thread-static.md) for a per-thread copy.

## Section `static`

A declaration block parallel to `var` and `const`, materialized as initialized data in the binary - no init code runs on any call:

```pascal
procedure bumper;
static
  cnt: integer = 0;             // explicit value
  s: string;                    // zero-init -> empty string
  greet := 'hello';             // inferred type
  buf: array[0..15] of byte;    // zero-init -> 16 bytes of zeros
begin
  inc(cnt);
  writeln(cnt);
end;

// bumper called 3 times -> outputs 1, 2, 3
```

Syntax forms:

```
static
  name [, name2, ...] : Type;             // zero-init
  name [, name2, ...] : Type = Value;     // explicit value (compile-time const)
  name := Value;                          // type inference (single name)
```

The initializer must be a **compile-time constant expression** (literal, named constant, simple fold) - a call or other runtime expression reports `Illegal expression`; use the inline form for those. Aggregate init for records and static arrays uses the typed-constant syntax `(field: val; ...)` / `(v1, v2)`. A missing initializer means zero-init (`0`, `False`, `nil`, empty for managed types, zeros recursively for records and arrays). Type inference (`:=`) follows the inline-var rules: char literal to the default string type, sub-32-bit integers to `LongInt`, explicit casts suppress promotion.

## Inline `static`

A single-statement declaration anywhere in a body, accepting runtime expressions evaluated **once on first reach**:

```pascal
function config: string;
begin
  static cached := loadConfig; // loadConfig runs once across all calls
  result := cached;
end;
```

Syntax forms:

```
static name : Type;
static name : Type := expr;
static name := expr;              // type inference (same rules as inline var)
```

Scope runs from the declaration to the end of the enclosing block, so an inline static inside a conditional branch is only declared (and its init only attempted) if the branch is reached:

```pascal
if condition then begin
  static x := 0; // declared / initialized only if this branch runs
  inc(x);
end;
```

## Init at most once (the guard)

When the initializer constant-folds, the inline form goes straight to the typed-constant data segment - no BSS slot, no guard, no branch, same cost as a section static. When the initializer is a runtime expression, the compiler emits a hidden Boolean guard plus one branch before the first use:

```pascal
if not __guard then begin
  __guard := true; // set BEFORE evaluating expr
  __var := <expr>;
end;
```

`__guard` is set **before** the expression runs, so:

- If `<expr>` raises, the exception propagates and the variable keeps its zero bytes. `__guard` is already true, so further calls skip the init block entirely - **no retry on failure**.
- If the init calls back into itself (reentrant init), the inner call sees `__guard = true` and reads the still-zero variable. Deterministic but rarely what you want - avoid recursive init expressions.

## Comparison

| Form | Lifetime | Scope | Initializer | Cost |
|---|---|---|---|---|
| `var x: T;` (in body) | call | block | none (zeroed) | stack alloc |
| `var x := V;` (inline var) | call | block | runtime expr | stack alloc + eval per call |
| `const x = V;` (in body) | program | block | compile-time | data segment, read-only |
| section `static` | program | block | compile-time, optional | data segment, writable, zero cost |
| inline `static` (const init) | program | block | compile-time | data segment, writable, zero cost |
| inline `static` (runtime init) | program | block | runtime expr | BSS + guard flag + first-call branch |

## Limitations

- Function / procedure / method bodies only.
- Section `static` rejects runtime expressions - use the inline form.
- No type / record / type-alias declarations inside `static` blocks - only variable declarations.
- The inline-static guard is per-declaration, not per-call site - two inline statics with the same name in different scopes get distinct guards.

## Demo

```pascal
program static_demo;

{$mode unleashed}

uses SysUtils;

var
  diskReads: integer = 0;

function loadConfig: string;
begin
  inc(diskReads);
  result := $'loaded-{diskReads}';
end;

// section static: a per-call counter at zero runtime cost
procedure ping;
static
  calls: integer = 0;
begin
  inc(calls);
  writeln($'ping #{calls}');
end;

// inline static with a runtime initializer: loadConfig runs once, ever
function config: string;
begin
  static cached := loadConfig;
  result := cached;
end;

// a table built once on first reach, then reused
function fib(n: integer): int64;
begin
  static memo: array[0..40] of int64;
  static ready: boolean;
  if not ready then begin
    memo[0] := 0; memo[1] := 1;
    for var i := 2 to 40 do memo[i] := memo[i-1]+memo[i-2];
    ready := true;
  end;
  result := memo[n];
end;

begin
  ping; ping; ping;
  writeln(config, ' / ', config, $' (disk reads: {diskReads})');
  writeln($'fib(10)={fib(10)} fib(40)={fib(40)}');
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
ping #1
ping #2
ping #3
loaded-1 / loaded-1 (disk reads: 1)
fib(10)=55 fib(40)=102334155
```
