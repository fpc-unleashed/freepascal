{ the nested method can carry more than one type parameter of its own,
  each specialized independently at the call site }
program nested_generics_two_type_params_05;
{$mode unleashed}

type
  TBox<T>=class
    function Two<U, V>(const a: U; const b: V): SizeInt;
  end;

function TBox<T>.Two<U, V>(const a: U; const b: V): SizeInt;
begin
  Result := SizeOf(U) + SizeOf(V);
end;

var
  b: TBox<Integer>;
begin
  b := TBox<Integer>.Create;
  if b.Two<Byte, Int64>(0, 0) <> 9 then Halt(1);
  if b.Two<Word, Word>(0, 0) <> 4 then Halt(2);
  b.Free;
end.
