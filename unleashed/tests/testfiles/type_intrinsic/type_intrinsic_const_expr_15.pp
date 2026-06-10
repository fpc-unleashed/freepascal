program type_intrinsic_const_expr_15;

{$mode unleashed}

var
  // Type() of a small constant expression: FPC picks the smallest fitting
  // ordinal subrange, e.g. SizeOf(Type(1+2)) is 1 byte
  y: Type(1 + 2);
  // Type() of an expression involving an already-typed Double var
  d: Double;
  z: Type(d * 2.0);
  // Type() of a long-literal computed expression keeps full width
  bigexpr: Type(Int64(1) shl 40);
begin
  y := 1;
  d := 1.5;
  z := 3.14;
  bigexpr := Int64(1) shl 50;
  if SizeOf(y) <> 1 then Halt(1);
  if SizeOf(z) <> SizeOf(Double) then Halt(2);
  if SizeOf(bigexpr) <> SizeOf(Int64) then Halt(3);
end.
