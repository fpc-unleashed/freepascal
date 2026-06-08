{ the nested method's type parameter can carry a constraint, and a
  descendant of the constraint type is accepted at the call site }
program nested_generics_constraint_09;
{$mode unleashed}

type
  TBase=class
    Tag: Integer;
  end;
  TDer=class(TBase)
  end;

  TBox<T>=class
    function Take<U: TBase>(const val: U): Integer;
  end;

function TBox<T>.Take<U>(const val: U): Integer;
begin
  Result := val.Tag;
end;

var
  b: TBox<Integer>;
  d: TDer;
begin
  b := TBox<Integer>.Create;
  d := TDer.Create;
  d.Tag := 99;
  if b.Take<TDer>(d) <> 99 then Halt(1);
  d.Free;
  b.Free;
end.
