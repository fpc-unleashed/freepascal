# Type() Intrinsic

`Type(expr)` is a compile-time intrinsic that yields the static type of an expression. It works wherever a type is required: declarations, typecasts, arguments to type-taking intrinsics, and derived types. The operand is never evaluated, so it can mention storage that does not exist at runtime (an empty dynamic array element, a nil pointer dereference, a not-yet-allocated object field).

Available in `{$mode unleashed}`; no separate modeswitch.

The name is `Type()` rather than `typeof()` because `typeof` already names a runtime VMT operator in classic Pascal dialects and reusing it would collide. `type` is a keyword that cannot normally be a function - the `(` right after it is what disambiguates the intrinsic (see below), and it does so without breaking any legal program.

## What it does

`Type(expr)` returns the type the expression would have if evaluated, without evaluating it. Purely compile-time: no code is generated for the operand, no side effects fire, no memory is read, no range check runs.

```pascal
var
  x: integer;
  y: Type(x); // y is integer
```

The operand can be anything that has a type: a variable, a field access, an array element, a function call, an arithmetic expression, an inferred-type identifier. The intrinsic walks the expression with the regular type-check pass and stops the moment the result type is known.

## Where it can appear

Every position that expects a type.

### Variable, field, parameter, function-result declarations

```pascal
var
  proto: integer;
  y: Type(proto); // var

type
  TBox = record
    slot: Type(proto); // field
  end;

function identity(v: Type(proto)): Type(proto); // parameter and result
begin
  result := v;
end;
```

### Typecasts

```pascal
var b: byte := 7;
r := Type(x)(b); // cast b to whatever type x has
```

### Arguments to type-taking intrinsics

`Default()`, `SizeOf()`, `BitSizeOf()`, `High()`, `Low()`, and the other intrinsics that accept a type name take `Type(expr)` in the same slot:

```pascal
d := Default(Type(s));
if sizeof(Type(s)) <> sizeof(pointer) then Halt(1);
```

### Derived types

`Type(expr)` carries through compound type constructors - arrays, pointers, sets, generic specialization arguments:

```pascal
var
  arr:  array of Type(proto);     // array of integer
  parr: ^Type(proto);             // ^integer
  cs:   set of Type(c);           // set of TColor
  box:  TBox<Type(proto)>;        // generic argument
```

### Weak and strong aliases

```pascal
type
  TInt     = Type(proto);         // weak alias - same type, interchangeable
  TIntCopy = type Type(proto);    // strong alias - a separate, incompatible type
```

The first form assigns straight through; the second goes through the usual `type X = type Y` strong-alias path and produces a fresh distinct type.

## Operand is not evaluated

The operand is parsed and type-checked, then the expression tree is discarded - nothing reaches code generation. Practical consequences:

- `Type(a[0])` is safe on an empty `array of T` - no read, no range check.
- `Type(someFunc())` does not call `someFunc`, so side effects never fire.
- `{$R+}` range checks do not run on `Type()` operands.
- The operand must still **type-check** - an undeclared identifier or illegal expression is still an error.

```pascal
var a: array of integer;
begin
  // a is empty - a[0] would range-check at runtime,
  // but Type(a[0]) only inspects the element type
  writeln(high(Type(a[0]))); // high(integer)
end;
```

## Swap idiom

The temp-variable swap reads cleanly without naming the type by hand (see also the [`SwapValues()`](swapvalues.md) builtin, which removes the temp entirely):

```pascal
var tmp: Type(a[0]);
tmp := a[i];
a[i] := a[j];
a[j] := tmp;
```

If the element type of `a` changes later, `tmp` follows without source edits.

## Use with inferred-type variables

`Type()` composes with inline-var inference - `Type(z)` names whatever type was inferred for `z`, so one inference site drives any number of downstream declarations:

```pascal
var z := makePoint(3, 4);       // z: TPoint (inferred)
var cache: array of Type(z);    // array of TPoint
var scalar: Type(z);            // TPoint
```

## Constant expression operands

The operand may be a constant expression. The resulting type is the **smallest type that fits the constant** - for small ordinals that is a tight subrange, not `integer`:

```pascal
var
  y: Type(1+2);                  // sizeof(y) = 1 (byte-sized subrange)
  big: Type(int64(1) shl 40);    // sizeof(big) = 8
```

To anchor the type, cast the constant (`Type(integer(5))`) or use a typed variable as the operand.

## Coexistence with the `type` keyword

`type` keeps its existing meanings - `type X = ...;` opens a declaration section, `type X = type Y;` is a strong alias. Disambiguation is purely syntactic: `Type` followed by `(` is the intrinsic; `type` followed by anything else is the keyword. The parser never guesses.

In other modes (`objfpc`, `delphi`, `fpc`) `Type(` in an expression or type position is rejected with the usual `Illegal expression` / type-expected errors - stock code compiles exactly as before.

## Diagnostics

- Undeclared identifier inside `Type()`: `Identifier not found "..."`.
- An anonymous type body (`record a: integer; end`) is not an expression - `Illegal expression`. Name the type first, then apply `Type()` to a value of it.
- A missing closing `)` reports the usual `")" expected but ... found`.

## Demo

```pascal
program type_intrinsic_demo;

{$mode unleashed}

var
  calls: integer = 0;

function expensive: double;
begin
  inc(calls);
  result := 3.14;
end;

begin
  var proto := 42;
  var copy: Type(proto) := proto; // follows proto's inferred type
  writeln($'copy = {copy}, sizeof = {sizeof(Type(proto))}');

  // the operand is type-checked but never evaluated
  var d: Type(expensive());
  d := 2.71;
  writeln($'d = {d:4:2}, expensive called {calls} time(s)');

  // safe on an empty dynamic array - no read, no range check
  var arr: array of integer;
  writeln($'high of element type = {high(Type(arr[0]))}');

  // swap without naming the type by hand
  var a := [3, 1];
  var tmp: Type(a[0]);
  tmp := a[0];
  a[0] := a[1];
  a[1] := tmp;
  writeln($'swapped: {a[0]}, {a[1]}');
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
copy = 42, sizeof = 4
d = 2.71, expensive called 0 time(s)
high of element type = 2147483647
swapped: 1, 3
```
