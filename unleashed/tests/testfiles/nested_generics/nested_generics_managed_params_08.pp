{ both the class T and the nested method U can be managed types, with a
  managed local of type U in the body - ARC must stay correct }
program nested_generics_managed_params_08;
{$mode unleashed}

type
  TBox<T>=class
    FV: T;
    function Take<U>(const a: T; const b: U): SizeInt;
  end;

function TBox<T>.Take<U>(const a: T; const b: U): SizeInt;
var
  loc: U;
begin
  FV := a;
  loc := b;
  Result := SizeOf(U);
end;

var
  b: TBox<string>;
begin
  b := TBox<string>.Create;
  b.Take<string>('outer', 'inner');
  if b.FV <> 'outer' then Halt(1);
  if b.Take<AnsiString>('x', 'y') <> SizeOf(Pointer) then Halt(2);
  b.Free;
end.
