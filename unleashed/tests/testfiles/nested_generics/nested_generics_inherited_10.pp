{ a non-generic descendant of a generic class inherits the nested generic
  method and can specialize it independently }
program nested_generics_inherited_10;
{$mode unleashed}

type
  TBase<T>=class
    function Sz<U>(const val: U): SizeInt;
  end;
  TDer=class(TBase<Integer>)
  end;

function TBase<T>.Sz<U>(const val: U): SizeInt;
begin
  Result := SizeOf(U);
end;

var
  d: TDer;
begin
  d := TDer.Create;
  if d.Sz<Int64>(0) <> 8 then Halt(1);
  if d.Sz<Byte>(0) <> 1 then Halt(2);
  d.Free;
end.
