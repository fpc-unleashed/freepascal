{ a local variable can have the nested method's type parameter as its
  type. the specialization allocates it at the right size and Default(U)
  / SizeOf(U) resolve per specialization }
program nested_generics_local_of_method_param_07;
{$mode unleashed}

type
  TBox<T>=class
    function Mk<U>: SizeInt;
  end;

function TBox<T>.Mk<U>: SizeInt;
var
  tmp: U;
begin
  tmp := Default(U);
  Result := SizeOf(tmp);
end;

var
  b: TBox<Integer>;
begin
  b := TBox<Integer>.Create;
  if b.Mk<Byte> <> 1 then Halt(1);
  if b.Mk<Double> <> 8 then Halt(2);
  b.Free;
end.
