{ the nested generic method can be a static class method - no instance
  needed, the class is specialized and the method picks its own U }
program nested_generics_class_method_11;
{$mode unleashed}

type
  TBox<T>=class
    class function Mk<U>: SizeInt; static;
  end;

class function TBox<T>.Mk<U>: SizeInt;
begin
  Result := SizeOf(U);
end;

begin
  if TBox<Integer>.Mk<Int64> <> 8 then Halt(1);
  if TBox<string>.Mk<Byte> <> 1 then Halt(2);
end.
