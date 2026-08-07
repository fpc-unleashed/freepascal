# Introduced Functions, Procedures and Intrinsics

Catalog of identifiers that Unleashed Pascal adds on top of stock FPC and that you can call from user code without any extra `uses` clause. Three categories:

- **Intrinsic** - recognized by the compiler itself, no symbol in any unit. Compile-time fold where possible, no overhead. Often gated on a modeswitch (typically `composablerecords`, default-on in `{$mode unleashed}`).
- **RTL `system`** - real routines living in the `system` unit. Available globally just like `GetMem()` or `writeln()`; no `uses` needed because `system` is implicit.
- **RTL other unit** - routines living in a non-implicit RTL unit; the relevant `uses` is noted next to the entry.

For each entry the table gives the signature in compact form, a one-line description, the category, and which feature page documents the surrounding context.

## Quick reference

| Name | Signature (compact) | Category | Gating | Documented in |
|---|---|---|---|---|
| `OffsetOf()` | `OffsetOf(T.field)` / `OffsetOf(T, field): SizeInt` | intrinsic | `{$modeswitch composablerecords}` (default in `unleashed`) | [composable-records.md](composable-records.md) |
| `BitOffsetOf()` | `BitOffsetOf(T.field)` / `BitOffsetOf(T, field): SizeInt` | intrinsic | `{$modeswitch composablerecords}` (default in `unleashed`) | [composable-records.md](composable-records.md) |
| `AlignOf()` | `AlignOf(T)` / `AlignOf(T.field): SizeInt` | intrinsic | `{$modeswitch composablerecords}` (default in `unleashed`) | [composable-records.md](composable-records.md) |
| `BitAlignOf()` | `BitAlignOf(T)` / `BitAlignOf(T.field): SizeInt` | intrinsic | `{$modeswitch composablerecords}` (default in `unleashed`) | [composable-records.md](composable-records.md) |
| `BitSizeOf()` (extended) | `BitSizeOf(T)` / `BitSizeOf(T.field): SizeInt` | intrinsic | always available; new behavior under `composablerecords` | [composable-records.md](composable-records.md) |
| `SwapValues()` | `procedure SwapValues(var a, b: T)` | intrinsic | `{$mode unleashed}` | [swapvalues.md](swapvalues.md) |
| `PreInc()` | `PreInc(var x[, n]): T` | intrinsic | `{$modeswitch prepostincdec}` (default in `unleashed`) | this page |
| `PostInc()` | `PostInc(var x[, n]): T` | intrinsic | `{$modeswitch prepostincdec}` (default in `unleashed`) | this page |
| `PreDec()` | `PreDec(var x[, n]): T` | intrinsic | `{$modeswitch prepostincdec}` (default in `unleashed`) | this page |
| `PostDec()` | `PostDec(var x[, n]): T` | intrinsic | `{$modeswitch prepostincdec}` (default in `unleashed`) | this page |
| `GetMemAligned()` | `function GetMemAligned(size, alignment: PtrUInt): Pointer` | RTL `system` | always available | [composable-records.md](composable-records.md) |
| `AllocMemAligned()` | `function AllocMemAligned(size, alignment: PtrUInt): Pointer` | RTL `system` | always available | [composable-records.md](composable-records.md) |
| `ReAllocMemAligned()` | `function ReAllocMemAligned(var p: Pointer; new_size, alignment: PtrUInt): Pointer` | RTL `system` | always available | [composable-records.md](composable-records.md) |
| `FreeMemAligned()` | `procedure FreeMemAligned(p: Pointer)` | RTL `system` | always available | [composable-records.md](composable-records.md) |

## Notes per entry

### `OffsetOf()` / `BitOffsetOf()`

Compile-time intrinsics that return the position of a field inside a record. Both accept Pascal-style `OffsetOf(T.field)` and C-style `OffsetOf(T, field)` separators and can mix them inside one call. The path is composition-aware: hops through `embed` carriers and through union variants accumulate the carrier offset along the chain.

`OffsetOf()` returns a byte offset. On a sub-byte field inside a bitpacked record where the bit position is not a multiple of 8 the compiler emits `OffsetOf("name") is not on a byte boundary - use BitOffsetOf instead`. `BitOffsetOf()` returns the bit offset and is always well-defined.

Pattern-detected in `factor_read_id`, no `system` symbol. Both can be used in `{$if}` conditionals, `const` sections, typed constants, inline `var` initializers - anywhere a constant is expected.

### `AlignOf()` / `BitAlignOf()`

Compile-time intrinsics that return the alignment requirement of a type or field. `AlignOf()` in bytes, `BitAlignOf()` in bits (`= AlignOf * 8` for plain types).

For a field reference both honor per-field overrides: `align N` for `AlignOf()`, `bitalign N` for `BitAlignOf()`. Without an override the result falls back to the field type's natural alignment. For a record / object / class type the value is the record-level alignment (max of field alignments).

Same surface as `OffsetOf()`: pattern-detected, usable in `{$if}` and any constant context.

### `BitSizeOf()` (extended)

Stock FPC already ships `BitSizeOf()`, returning the storage bits a field actually occupies in a bitpacked context. Under `composablerecords` the same intrinsic also honors the per-field `bitsize N` modifier, so a wide type narrowed by `bitsize N` reports `N` rather than the type's natural bit width. Behavior outside `composablerecords` is unchanged.

### `SwapValues()`

Builtin that swaps two same-typed assignable variables with a bitwise move, no `uses` required. For managed types (string, dynamic array, interface, `Variant`) it swaps only the reference words, with no `incr_ref` / `decr_ref` calls; ordinals and pointer-sized operands lower to a register swap, larger types to a raw byte exchange. An operand with a side-effecting address is evaluated once. Pattern-detected in `factor_read_id` in `{$mode unleashed}`, but only when no `SwapValues()` symbol is in scope, so a user-declared `SwapValues()` keeps resolving normally and shadows the builtin.

### `PreInc()` / `PostInc()` / `PreDec()` / `PostDec()`

Pre/post increment and decrement as value-returning builtins. All four update the operand like `inc()` / `dec()` and additionally yield a value: the `Pre` pair returns the value after the update, the `Post` pair the value read before it.

```pascal
var i := 10;
a := PostInc(i);      // a = 10, i = 11
a := PreInc(i);       // a = 12, i = 12
a := PostDec(i, 3);   // a = 12, i = 9
a := PreDec(i, 4);    // a = 5,  i = 5
```

The optional second parameter is the step, exactly as in `inc()` / `dec()`; it may be negative. The accepted operand types match `inc()` / `dec()`: integers, enums, chars, currency, and pointers (the step counts elements, not bytes). Records with a `class operator Inc` / `Dec` work too: the operator supplies the new value and the old or new one is returned accordingly.

A side-effecting operand address is evaluated once, so `PostInc(a[f()])` calls `f()` a single time. Properties go through the same getter/setter rewrite as `inc()` on a property: the getter and the setter each run exactly once per call. In statement position the value is simply discarded, so `PostInc(x);` behaves like `inc(x)`.

The updates are not atomic, same as `inc()` / `dec()`. For a thread-safe counter use `AtomicIncrement()` (returns the new value, like `PreInc()`) or `InterlockedExchangeAdd()` (returns the old one, like `PostInc()`).

Pattern-detected in the parser under the `prepostincdec` modeswitch (default-on in `{$mode unleashed}`), but only when no symbol of that name is in scope, so a user-declared `PreInc()` etc. keeps resolving normally and shadows the builtin.

### `GetMemAligned()` / `AllocMemAligned()` / `ReAllocMemAligned()` / `FreeMemAligned()`

Aligned heap allocator added to the `system` unit. The allocation carries a small preamble with the unaligned base pointer and the requested size, so the free path can recover the original block without bookkeeping on the caller side.

- `GetMemAligned(size, alignment)` allocates `size` bytes aligned to a power-of-two `alignment` (at least `SizeOf(Pointer)`). Contents undefined.
- `AllocMemAligned(size, alignment)` same as above but zero-filled.
- `ReAllocMemAligned(var p, new_size, alignment)` resizes while keeping the alignment guarantee. `p = nil` acts as alloc, `new_size = 0` acts as free.
- `FreeMemAligned(p)` releases an aligned block; tolerates `p = nil`.

The allocator is independent of the heap manager that backs `GetMem()` / `FreeMem()` and uses it underneath, so any custom memory manager set via `SetMemoryManager()` is respected.

Important: do not mix the families. A pointer returned by `GetMemAligned()` / `AllocMemAligned()` must be freed with `FreeMemAligned()`, and a pointer returned by `GetMem()` / `AllocMem()` must not be passed to `FreeMemAligned()`.

Implementation lives in `rtl/inc/alignmem.inc`, included from `rtl/inc/system.inc` after the heap implementation; forwards sit in `rtl/inc/heaph.inc` next to `GetMem()` / `AllocMem()`.

## Demo

Exercises the layout intrinsics, the aligned allocator, `SwapValues()`, and the pre/post inc/dec builtins - none of which needs a `uses` clause:

```pascal
program introduced_demo;

{$mode unleashed}

type
  TCoord = record
    lo, hi: word;
  end;

  TPacket = record
    magic: longword;
    embed TCoord; // lo, hi flatten in
    payload: array[0..3] of byte;
  end;

const
  OFF_HI = OffsetOf(TPacket.hi); // composition-aware, hops the embed
  OFF_PAYLOAD = OffsetOf(TPacket, payload);
  AL_PACKET = AlignOf(TPacket);
  AL_DOUBLE = AlignOf(double);

begin
  writeln($'OffsetOf(TPacket.hi) = {OFF_HI}');
  writeln($'OffsetOf(TPacket, payload) = {OFF_PAYLOAD}');
  writeln($'AlignOf(TPacket) = {AL_PACKET}, AlignOf(double) = {AL_DOUBLE}');

  // aligned heap: line up a buffer on a 64-byte boundary
  var p := GetMemAligned(256, 64);
  writeln($'GetMemAligned(256, 64) aligned: {PtrUInt(p) and 63 = 0}');
  FreeMemAligned(p);

  // SwapValues needs no uses clause
  var a := 1; var b := 2;
  SwapValues(a, b);
  writeln($'after swap: a={a} b={b}');

  // pre/post inc/dec return a value
  var i := 10;
  writeln($'PostInc(i) = {PostInc(i)}, i is now {i}');
  writeln($'PreInc(i, 5) = {PreInc(i, 5)}');
  writeln($'PostDec(i) = {PostDec(i)}, PreDec(i) = {PreDec(i)}');
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
OffsetOf(TPacket.hi) = 6
OffsetOf(TPacket, payload) = 8
AlignOf(TPacket) = 4, AlignOf(double) = 8
GetMemAligned(256, 64) aligned: TRUE
after swap: a=2 b=1
PostInc(i) = 10, i is now 11
PreInc(i, 5) = 16
PostDec(i) = 16, PreDec(i) = 14
```
