# Type() Intrinsic

`Type(expr)` is a compile-time intrinsic that yields the static type of an expression. It works wherever a type is required: declarations, typecasts, arguments to type-taking intrinsics, and derived types. The operand is never evaluated, so it can mention storage that does not exist at runtime (an empty dynamic array element, a null pointer dereference, a not-yet-allocated object field).

Available in `{$mode unleashed}`. There is no separate modeswitch; it ships with the rest of the unleashed feature set.

```pas
{$mode unleashed}
```

This is the Pascal counterpart of C++'s `decltype` and D's `typeof`. The name `Type()` is taken instead of `typeof()` because `typeof` already names a runtime RTTI / VMT operator in classic Pascal, and `type` is a keyword that cannot be reused as a function. The `(` disambiguates the intrinsic from the `type` keyword.

## What it does

`Type(expr)` returns the type that the expression would have if evaluated, without evaluating it. It is purely a compile-time operation: no code is generated for the operand, no side effects fire, no memory is read, no range check runs.

```pas
var
  x: Integer;
  y: Type(x);   // y is Integer
begin
  y := x;
end;
```

The operand can be anything that has a type: a simple variable, a field access, an array element, a function call, an arithmetic expression, an inferred-type identifier, a record literal value. The intrinsic walks the expression with the regular type-check pass and stops the moment the result type is known.

## Where it can appear

`Type(expr)` is valid in every position that expects a type.

### Variable, field, parameter, function-result declarations

```pas
var
  proto: Integer;
  y: Type(proto);                       // var

type
  TBox = record
    slot: Type(proto);                  // field
  end;

function Identity(v: Type(proto)): Type(proto);   // parameter and result
begin
  Result := v;
end;
```

### Typecasts

```pas
var
  x: Integer;
  b: Byte;
  r: Integer;
begin
  b := 7;
  r := Type(x)(b);   // cast b to whatever type x has
end;
```

### Arguments to type-taking intrinsics

`Default`, `SizeOf`, `BitSizeOf`, `High`, `Low`, and others that accept a type name accept `Type(expr)` in the same slot.

```pas
var
  s: AnsiString;
  d: Type(s);
begin
  d := Default(Type(s));
  if SizeOf(Type(s)) <> SizeOf(Pointer) then Halt(1);
end;
```

### Derived types

`Type(expr)` can carry through to compound type constructors: arrays, pointers, sets, generic specializations.

```pas
var
  proto: Integer;
  c: TColor;

var
  arr:  array of Type(proto);             // array of Integer
  parr: ^Type(proto);                     // ^Integer
  cs:   set of Type(c);                   // set of TColor
  list: TFPGList<Type(proto)>;            // generic argument
```

### Strong alias of a `Type()` result

```pas
type
  TInt    = Type(proto);          // alias: same type, freely interchangeable
  TIntCopy = type Type(proto);    // strong alias: a separate, incompatible type
```

The first form (`= Type(...)`) is an alias and assigns straight through. The second form (`= type Type(...)`) goes through the usual `type X = type Y` strong-alias path, producing a fresh distinct type.

## Operand is not evaluated

This is the property that makes `Type()` useful for generic and metaprogramming patterns. The operand is parsed and type-checked, then the expression tree is discarded. Nothing reaches code generation.

```pas
var
  a: array of Integer;
begin
  // a is empty - a[0] would range-check at runtime
  // but Type(a[0]) only inspects the element type, no read happens
  WriteLn(High(Type(a[0])));   // prints High(Integer)
end;
```

Practical consequences:

- `Type(a[0])` is safe on an empty `array of T`, an uninitialized variant, a null `obj.field`. No memory is touched.
- `Type(SomeFunc())` does not call `SomeFunc`, so a function with side effects or `noreturn` semantics is fine inside `Type()`.
- Range checks (`{$R+}`) do not fire on `Type()` operands.
- The compiler still requires the operand to **type-check**. An undeclared identifier, an illegal expression, or a missing field is still an error.

## Swap idiom

The common temp-variable swap reads cleanly without naming the type by hand:

```pas
var A: array of Integer;
    i, j: Integer;
begin
  var tmp: Type(A[0]);
  tmp  := A[i];
  A[i] := A[j];
  A[j] := tmp;
end;
```

If the type of `A` changes later, `tmp` follows without source edits.

## Use with inferred-type variables

`Type()` composes with inline-var type inference. `Type(z)` names the type that was inferred for `z`, so a single inference site can drive multiple downstream declarations.

```pas
type
  TPoint = record x, y: Integer end;
function MakePoint(ax, ay: Integer): TPoint;

begin
  var z := MakePoint(3, 4);          // z is TPoint (inferred)
  var cache: array of Type(z);       // array of TPoint
  var scalar: Type(z);               // TPoint
end;
```

## Constant expression operands

The operand can be a constant expression. The resulting type is the **smallest type that fits the constant** that the compiler would assign to a typed-constant declaration. For small ordinal constants this is a tight subrange, not `Integer`:

```pas
var
  y: Type(1 + 2);              // SizeOf(y) = 1 (byte-sized subrange)
  bigexpr: Type(Int64(1) shl 40);   // SizeOf(bigexpr) = SizeOf(Int64)
```

To anchor the type, cast the constant into the type you want, or use a typed variable as the operand:

```pas
const C: Integer = 5;
var y1: Type(C);          // Integer
var y2: Type(Integer(5)); // Integer
```

## Coexistence with the `type` keyword

`type` keeps its existing meanings:

- `type X = ...;` opens a type-declaration section.
- `type X = type Y;` is a strong alias.

Disambiguation is purely syntactic: `Type` followed by `(` is the intrinsic, `type` followed by anything else (identifier, `record`, etc.) is the keyword. The parser never has to guess.

In other modes (`objfpc`, `delphi`, `fpc`, etc.) `Type(` is rejected with the usual "Illegal expression" / "Type identifier expected" message. Stock Pascal code continues to compile as before.

## Diagnostics

- An undeclared identifier inside `Type()` reports `Identifier not found "..."`.
- An anonymous record literal (`record a: Integer; end`) is not a valid expression in Pascal and yields `Illegal expression`. Define the record as a named type first, then use `Type()` on a value of it.
- A missing closing `)` reports the usual `")" expected but ... found`.

## Why not name it `decltype` or `typeof`

- `typeof` is already in use in some dialects of Object Pascal for an RTTI / VMT operator (`typeof(SomeClass)` returns the class reference). Reusing the name would collide.
- `decltype` is a C++ word and reads alien in Pascal source.
- `Type()` reuses an existing reserved word in a way that does not break any legal program: in classic Pascal `type` always introduces a type-declaration block (no `(` follows), so the new form is unambiguous against every prior use.
