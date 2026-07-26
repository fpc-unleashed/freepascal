# SwapValues

`SwapValues(a, b)` swaps the values of two same-typed variables. It is a compiler builtin: no unit, no `uses`, no generic syntax. It works with only the implicit `System` unit in scope, like `Inc`, `Dec`, or `SetLength`.

Available in `{$mode unleashed}`. There is no separate modeswitch.

```pas
{$mode unleashed}
```

## What it does

`SwapValues(a, b)` exchanges the contents of `a` and `b`. Both must be assignable (a variable, field, array element, or dereferenced pointer) and of the same type.

```pas
var i, j: Integer;
begin
  i := 1; j := 2;
  SwapValues(i, j);   // i = 2, j = 1
end;
```

The swap is a bitwise move. For an ordinal or pointer-sized operand the compiler emits a register swap; for a larger type it exchanges the raw bytes. Either way no helper is called.

## Why a builtin, and why the name

SysUtils already ships `generic procedure Swap<T>` and `generic function Exchange<T>`, and at `-O3` they compile to the same optimal code. The reason for a builtin is to drop the unit dependency: pulling in SysUtils just to swap two variables drags in exception setup, replaced error and assertion handlers, and noticeable binary growth. `SwapValues` costs nothing beyond the swap itself, so minimal-RTL, low-level, and gamedev code that uses only `System` can swap two variables without paying for SysUtils.

The name `SwapValues` is deliberately fresh. `Swap` and `Exchange` both already name routines: `System.Swap` is the one-argument byte-half-swap, and SysUtils ships `Swap<T>` and a differently-shaped `Exchange<T>` (`function Exchange<T>(var target; const newvalue): T`). Reusing either name forces a collision with those overloads. `SwapValues` has no such clash, reads at a glance like what it does, and stays out of the way of any code already using `Swap` or `Exchange`.

## Managed types: no reference-count churn

For managed types (`string`, dynamic array, interface, `Variant`) the swap exchanges the reference words bitwise. A naive `tmp := a; a := b; b := tmp` would emit `incr_ref` / `decr_ref` (or `fpc_ansistr_assign`) on every step; `SwapValues` emits none. The two variables trade ownership, total reference counts are preserved, so swapping in a loop neither leaks nor double-frees.

```pas
var s, t: string;
begin
  s := 'left'; t := 'right';
  SwapValues(s, t);   // s = 'right', t = 'left', no refcount calls
end;
```

## Codegen

For an ordinal the swap is four moves through a register, with no stack temporary:

```
movl   gj(%rip), %eax
movl   gi(%rip), %edx
movl   %edx, gj(%rip)
movl   %eax, gi(%rip)
```

For a string (or any pointer-sized managed type) only the two reference words move, with no reference-count calls:

```
movq   (%rdx), %rax
movq   (%rcx), %r8
movq   %r8, (%rdx)
movq   %rax, (%rcx)
```

An argument whose address has side effects (e.g. `arr[NextIndex]`) has that address taken once, so each operand is evaluated exactly once.

## Same variable twice

`SwapValues(x, x)` is a harmless no-op: it reads and writes the same storage, leaving the value unchanged and, for a managed type, the reference count untouched. It is not an error.

## Property operands

A property read through a getter has no address, so it cannot take the in-place path. `SwapValues` still accepts it: when either operand is such a property, the swap expands through a hidden temporary that drives the accessors, the same way `Inc(obj.Prop)` expands to `obj.SetProp(obj.GetProp + 1)`:

```pas
SwapValues(obj.A, obj.B);
// expands to:
// tmp := obj.GetA;
// obj.SetA(obj.GetB);
// obj.SetB(tmp);
```

The two modes are picked automatically:

- both operands addressable (variable, field, array element, dereference, or a property that reads and writes the same plain field): the in-place bitwise swap, unchanged;
- any operand without an address: the temporary expansion. An addressable operand mixed in simply reads and writes its storage directly, so property-with-variable works with the same expansion.

The property must have both a read and a write specifier; a read-only or write-only property is rejected with an error saying so. Array properties work, including a side-effecting index expression: the index, like the instance expression, is evaluated exactly once for the whole swap:

```pas
SwapValues(obj.Items[Next()], x);
// expands to:
// i := Next();                    // once
// tmp := obj.GetItem(i);
// obj.SetItem(i, x);
// x := tmp;
```

### Cost and atomicity

The expansion calls one getter and one setter per property operand (up to 2 getters and 2 setters for property-with-property), and for a managed type the temporary does reference counting the accessors demand. Since setters run user code, the exchange is not atomic: a setter can execute arbitrary code and observe the state mid-swap.

Because those calls are invisible in the source, the expansion emits a hint per property operand:

```
Hint: SwapValues on "A" is not an in-place swap: it uses a temporary and calls the getter and setter of each property operand
```

Silence it with any of the standard forms:

```pas
{$WARN 4141 OFF}
SwapValues(obj.A, x);
{$WARN 4141 ON}

{$push}{$HINTS OFF}
SwapValues(obj.A, x);
{$pop}

{$push}{$WARN 4141 OFF}
SwapValues(obj.A, x);
{$pop}
```

## Diagnostics

- A non-assignable argument (literal, constant, function result) is rejected.
- A property operand must have both read and write specifiers; `Property "X" has no write accessor` otherwise.
- The two arguments must be the same type, otherwise `Type mismatch`.
- Exactly two arguments are required, one or three gives `Wrong number of parameters`.

## Coexistence

`SwapValues` is recognized as the builtin only in `{$mode unleashed}`, and only when no `SwapValues` symbol is in scope. A user-declared `SwapValues` (variable, routine, type) resolves normally and shadows the builtin. Outside unleashed mode `SwapValues` is an ordinary identifier with no special meaning, so legacy code that uses the name keeps compiling unchanged.
