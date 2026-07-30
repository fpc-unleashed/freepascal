# SwapValues()

`SwapValues(a, b)` swaps the values of two same-typed variables. It is a compiler builtin: no unit, no `uses`, no generic syntax. It works with only the implicit `System` unit in scope, like `Inc()`, `Dec()`, or `SetLength()`.

Available in `{$mode unleashed}`; no separate modeswitch.

## What it does

`SwapValues(a, b)` exchanges the contents of `a` and `b`. Both must be assignable (a variable, field, array element, or dereferenced pointer - a property works too, see below) and of the same type.

```pascal
var i, j: integer;
begin
  i := 1; j := 2;
  SwapValues(i, j); // i = 2, j = 1
end;
```

The swap is a bitwise move. For an ordinal or pointer-sized operand the compiler emits a register swap; for a larger type it exchanges the raw bytes. Either way no helper is called.

## Why a builtin, and why the name

SysUtils already ships `generic procedure Swap<T>` and `generic function Exchange<T>`, and at `-O3` they compile to the same optimal code. The reason for a builtin is to drop the unit dependency: pulling in SysUtils just to swap two variables drags in exception setup, replaced error and assertion handlers, and noticeable binary growth. `SwapValues()` costs nothing beyond the swap itself, so minimal-RTL, low-level, and gamedev code that uses only `System` can swap two variables without paying for SysUtils.

The name `SwapValues()` is deliberately fresh. `Swap()` and `Exchange()` both already name routines: `System.Swap` is the one-argument byte-half-swap, and SysUtils ships `Swap<T>` and a differently-shaped `Exchange<T>` (`function Exchange<T>(var target; const newvalue): T`). Reusing either name forces a collision with those overloads. `SwapValues()` has no such clash, reads at a glance like what it does, and stays out of the way of any code already using `Swap()` or `Exchange()`.

## Managed types: no reference-count churn

For managed types (`string`, dynamic array, interface, `Variant`) the swap exchanges the reference words bitwise. A naive `tmp := a; a := b; b := tmp` would emit `incr_ref` / `decr_ref` (or `fpc_ansistr_assign`) on every step; `SwapValues()` emits none. The two variables trade ownership, total reference counts are preserved, so swapping in a loop neither leaks nor double-frees.

```pascal
var s, t: string;
begin
  s := 'left'; t := 'right';
  SwapValues(s, t); // s = 'right', t = 'left', no refcount calls
end;
```

## Codegen

For an ordinal the swap is four moves through registers, with no stack temporary:

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

An argument whose address has side effects (e.g. `arr[nextIndex()]`) has that address taken once, so each operand is evaluated exactly once.

## Same variable twice

`SwapValues(x, x)` is a harmless no-op: it reads and writes the same storage, leaving the value unchanged and, for a managed type, the reference count untouched. It is not an error.

## Property operands

A property read through a getter has no address, so it cannot take the in-place path. `SwapValues()` still accepts it: when either operand is such a property, the swap expands through a hidden temporary that drives the accessors, the same way `inc(obj.prop)` expands to `obj.setProp(obj.getProp + 1)`:

```pascal
SwapValues(obj.a, obj.b);
// expands to:
// tmp := obj.getA;
// obj.setA(obj.getB);
// obj.setB(tmp);
```

The two modes are picked automatically:

- both operands addressable (variable, field, array element, dereference, or a property that reads and writes the same plain field): the in-place bitwise swap, unchanged;
- any operand without an address: the temporary expansion. An addressable operand mixed in simply reads and writes its storage directly, so property-with-variable and property-with-field-property work with the same expansion.

The property must have both a read and a write specifier; a read-only or write-only property is rejected with a dedicated error. Array properties work, including a side-effecting index expression: the index, like the instance expression, is evaluated exactly once for the whole swap:

```pascal
SwapValues(obj.items[next()], x);
// expands to:
// i := next();                    // once
// tmp := obj.getItem(i);
// obj.setItem(i, x);
// x := tmp;
```

### Cost and atomicity

The expansion calls one getter and one setter per accessor-driven operand (up to 2 getters and 2 setters for property-with-property), and for a managed type the temporary does the reference counting the accessors demand. Since setters run user code, the exchange is not atomic: a setter can execute arbitrary code and observe the state mid-swap.

Because those calls are invisible in the source, the expansion emits hint 4141 per accessor-driven property operand (hints are shown with `-vh` on the command line; the Lazarus IDE shows them by default):

```
Hint: SwapValues on "a" is not an in-place swap: it uses a temporary and calls the getter and setter of each property operand
```

Silence it with any of the standard forms:

```pascal
{$warn 4141 off}
SwapValues(obj.a, x);
{$warn 4141 on}

{$push}{$hints off}
SwapValues(obj.a, x);
{$pop}
```

## Diagnostics

| Situation | Message |
|---|---|
| Non-assignable argument (literal, constant, function result) | `Variable identifier expected` |
| Property operand without a write accessor | `Property "X" has no write accessor` |
| Arguments of different types | `Type mismatch` |
| One argument or three and more | `Wrong number of parameters specified for call to "SwapValues"` |

## Coexistence

`SwapValues()` is recognized as the builtin only in `{$mode unleashed}`, and only when no `SwapValues()` symbol is in scope. A user-declared `SwapValues()` (variable, routine, type) resolves normally and shadows the builtin:

```pascal
procedure SwapValues(a, b: integer);
begin
  writeln('user routine wins: ', a, ' ', b);
end;

begin
  SwapValues(1, 2); // calls the user routine, prints "user routine wins: 1 2"
end.
```

Outside unleashed mode `SwapValues()` is an ordinary identifier with no special meaning, so legacy code that uses the name keeps compiling unchanged.

## Demo

```pascal
program swap_values_demo;

{$mode unleashed}

begin
  // bubble sort in place - SwapValues needs no uses clause
  var a := [5, 2, 9, 1, 7];
  for var pass := high(a) downto 1 do
    for var i := 0 to pass-1 do
      if a[i] > a[i+1] then SwapValues(a[i], a[i+1]);
  for var v in a do write(v, ' ');
  writeln;

  // managed types trade ownership bitwise - no refcount churn
  var s := 'left';
  var t := 'right';
  SwapValues(s, t);
  writeln(s, ' | ', t);

  // records swap as raw bytes
  var p1: record x, y: integer; end := (x: 1; y: 2);
  var p2: Type(p1) := (x: 30; y: 40);
  SwapValues(p1, p2);
  writeln($'p1=({p1.x},{p1.y}) p2=({p2.x},{p2.y})');
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
1 2 5 7 9
right | left
p1=(30,40) p2=(1,2)
```
