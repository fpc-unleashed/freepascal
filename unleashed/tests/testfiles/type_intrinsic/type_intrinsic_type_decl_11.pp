program type_intrinsic_type_decl_11;

{$mode unleashed}

var
  x: Integer;

type
  // type-decl form: Foo is alias for the type of x (Integer)
  TFoo = Type(x);
  // strong-alias of Type(): Foo2 is a unique copy of the type of x
  TFoo2 = type Type(x);

var
  a: TFoo;
  b: TFoo2;
begin
  a := 100;
  b := TFoo2(200);
  if a + Integer(b) <> 300 then Halt(1);
  if SizeOf(TFoo) <> SizeOf(Integer) then Halt(2);
  if SizeOf(TFoo2) <> SizeOf(Integer) then Halt(3);
end.
