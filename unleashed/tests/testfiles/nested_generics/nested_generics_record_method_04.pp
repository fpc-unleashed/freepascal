{ the enclosing type can be a generic record, not only a class. the
  record carries a generic method with its own type parameter }
program nested_generics_record_method_04;
{$mode unleashed}

type
  TPair<T>=record
    FA: T;
    function Wrap<U>(const a: T; const b: U): SizeInt;
  end;

function TPair<T>.Wrap<U>(const a: T; const b: U): SizeInt;
begin
  FA := a;
  Result := SizeOf(U);
end;

var
  p: TPair<Integer>;
begin
  if p.Wrap<Byte>(1, 0) <> 1 then Halt(1);
  if p.Wrap<Int64>(2, 0) <> 8 then Halt(2);
  if p.FA <> 2 then Halt(3);
end.
