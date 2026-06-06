# Static Variables

Declare variables with program-wide lifetime but block-local scope. Two flavors:

- **Section static** (`STATICSECTION` modeswitch): a `static` declaration block that takes compile-time constant initializers, like `const`-with-types but writeable. Zero runtime cost.
- **Inline static** (`INLINESTATIC` modeswitch): `static name := expr;` inline declaration anywhere in a body. Accepts runtime expressions, evaluated once on first reach.

Both are enabled by default in `{$mode unleashed}`. Outside unleashed:

```pas
{$mode objfpc}
{$modeswitch staticsection}
{$modeswitch inlinestatic}
```

Both are allowed **only inside function/procedure/method bodies**. Using them at unit/program level produces:

```
Error: static is only allowed in function/procedure bodies
```

At unit or program level, plain `var` already gives program lifetime and is the right tool.

## Why static

A `static` variable behaves like a typed constant that is writeable: program lifetime, hidden behind a local name. The C equivalent is `static int x;` inside a function. Use cases:

- Per-call counters that survive between calls
- Lazy one-time computation cached in the function
- Default values that the function may mutate

```pas
procedure Bumper;
static
  cnt: Integer = 0;
begin
  Inc(cnt);
  WriteLn(cnt);
end;

begin
  Bumper;  // 1
  Bumper;  // 2
  Bumper;  // 3
end.
```

The variable is **not** a thread-local. Multiple threads hitting the same function share the same `cnt`; the user handles thread safety.

## Section `static`

A declaration block at the top of a function body, parallel to `var` and `const`:

```pas
procedure Foo;
static
  x: Integer;             // zero-init
  y: Integer = 42;        // explicit value
  s: string;              // zero-init -> empty string
  greet := 'hello';       // inferred type (default string flavor)
  ratio := 3.14;          // inferred type (Extended)
  buf: array[0..15] of Byte;   // zero-init -> 16 bytes of zeros
begin
  ...
end;
```

### Syntax forms

```
static
  name [, name2, ...] : Type;             // zero-init
  name [, name2, ...] : Type = Value;     // explicit value
  name := Value;                          // type inference (single name)
```

### Initializer rules

- The initializer (after `=` or `:=`) must be a **compile-time constant expression**: literal, named constant, simple constant fold. Calls and runtime expressions are rejected. If you need a runtime initializer, use inline static.
- When no initializer is given, the variable is zero-initialized: `0` for ordinals, `False` for booleans, `nil` for pointers/classes/strings, empty for managed types, zeros for records and arrays recursively.
- Aggregate-literal initializers for records and static arrays use the typed-constant syntax `(field: val; ...)` / `(v1, v2, ...)`.

### Type inference (`:=` only)

Same rules as inline `var`:

- Single character `'x'` -> default string type (`string` / `UnicodeString` / `ShortString` depending on modeswitches).
- String literal -> default string type.
- Sub-Int32 integers (`Byte`, `ShortInt`, `Word`, `SmallInt`) -> `LongInt` (Int32). Explicit casts (`Byte(10)`) suppress promotion.

### Zero runtime cost

Section static is materialized as initialized data in the binary. First call reads the bytes from the data segment, no init code runs. Subsequent calls are identical to regular variable access.

## Inline `static`

A single-statement declaration anywhere inside a body:

```pas
procedure Foo;
begin
  WriteLn('start');
  static cnt := 0;             // first reach: cnt := 0
  Inc(cnt);
  static greet := 'world';     // first reach: greet := 'world'
  WriteLn(cnt, ' ', greet);
end;
```

### Syntax forms

```
static name : Type;
static name : Type := expr;
static name := expr;       // type inference
```

### Runtime expressions allowed

```pas
procedure ReadConfigOnce;
begin
  static cfg := LoadConfigFromDisk;   // LoadConfigFromDisk runs once
  Use(cfg);
end;
```

The expression is evaluated **once**, on the first reach of the declaration. Subsequent calls skip the initialization and read the cached value.

### Init runs at most once (the guard)

The compiler emits a hidden Boolean guard variable next to the static. The generated logic is:

```pas
if not __guard then
begin
  __guard := True;       // set BEFORE evaluating the expression
  __var := <expr>;
end;
```

Setting `__guard` before evaluation means:

- If `<expr>` raises, the exception propagates normally. The variable keeps its zero bytes. `__guard` is already true, so further calls skip the init block entirely. **No retry.**
- If the function is reentrant and the init expression calls back into itself, the inner call sees `__guard = True` and bypasses the init - it reads the variable while still zero. This avoids infinite recursion but gives deterministic, possibly surprising, intermediate values for reentrant init scenarios.

### Recursive init example

```pas
function ComputeInitial(n: Integer): Integer; forward;

function Foo(n: Integer): Integer;
begin
  static cache := ComputeInitial(n);
  Result := cache + n;
end;

function ComputeInitial(n: Integer): Integer;
begin
  if n > 0 then
    Result := Foo(n - 1) * 2
  else
    Result := 1;
end;
```

`Foo(3)`:

1. `__cache_guard = False`, enter init block.
2. `__cache_guard := True`.
3. Evaluate `ComputeInitial(3)`.
4. `ComputeInitial(3)` calls `Foo(2)`.
5. In the nested `Foo(2)`: `__cache_guard = True`, skip init, `cache` is still 0. Return `0 + 2 = 2`.
6. Back in `ComputeInitial(3)`: `Result := 2 * 2 = 4`.
7. Back in outer `Foo(3)`: `cache := 4`. Return `4 + 3 = 7`.

The recursive call sees the uninitialized `cache`. Avoid recursive init expressions if this matters; the deterministic behavior is documented but rarely what you want.

### Anywhere in the body

Inline static may appear at any statement position, like inline var. Scope runs from the declaration to the end of the enclosing block.

```pas
procedure Foo;
begin
  if Condition then
  begin
    static x := 0;   // only declared if this branch runs at least once
    Inc(x);
  end;
end;
```

### Cost

One hidden flag (1 byte, BSS) plus one branch before the first use in every call. Cheap but not zero. If the initializer is a compile-time constant and you want zero cost, use section `static` instead.

## Differences from related features

| Feature | Lifetime | Scope | Initializer | Cost |
|---|---|---|---|---|
| `var x: T;` (in body) | call | block | none (zeroed) | stack alloc |
| `var x := V;` (inline var) | call | block | runtime expr | stack alloc + eval per call |
| `const x = V;` (in body) | program | block | compile-time | data segment, read-only |
| section `static` | program | block | compile-time, optional | data segment, writeable |
| inline `static` | program | block | runtime expr, optional | BSS + flag + first-call branch |

## Threading

Static variables (both flavors) share a single instance across all threads. There is no implicit synchronization. If multiple threads can hit the same `static`, the user is responsible for locks, atomics, or thread-locals (`threadvar` at unit level).

## Limitations

- Allowed only in function/procedure/method bodies. Not at unit interface, unit implementation, or program top level (there, plain `var` is equivalent).
- Section `static` rejects runtime-only expressions. Use inline `static` for those.
- No type alias / type / record declarations inside `static` blocks - only variable declarations.
- The hidden guard for inline static is per-declaration, not per-call site. Two inline static declarations with the same name in different scopes get distinct guards.
