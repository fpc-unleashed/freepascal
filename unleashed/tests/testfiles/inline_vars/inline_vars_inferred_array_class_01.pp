program inline_vars_inferred_array_class_01;
{$mode unleashed}

type
  TFoo = class
    Value: Integer;
    constructor Create(AValue: Integer);
  end;

constructor TFoo.Create(AValue: Integer);
begin
  Value := AValue;
end;

begin
  var a := [TFoo.Create(10), TFoo.Create(20), TFoo.Create(30)];
  if Length(a) <> 3 then halt(1);
  if SizeOf(a[0]) <> SizeOf(Pointer) then halt(2);  // class is a pointer
  if a[0].Value <> 10 then halt(3);
  if a[1].Value <> 20 then halt(4);
  if a[2].Value <> 30 then halt(5);
  // each element is an actual TFoo instance, not a different class
  if not (a[0] is TFoo) then halt(6);
  if not (a[1] is TFoo) then halt(7);
  if not (a[2] is TFoo) then halt(8);
  a[0].Free;
  a[1].Free;
  a[2].Free;
end.
