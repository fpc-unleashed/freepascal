{ the nested method's result type can be its own type parameter, not the
  class T - the return slot is resolved per method specialization }
program nested_generics_returns_method_param_06;
{$mode unleashed}

type
  TBox<T>=class
    function Echo<U>(const x: U): U;
  end;

function TBox<T>.Echo<U>(const x: U): U;
begin
  Result := x;
end;

var
  b: TBox<string>;
begin
  b := TBox<string>.Create;
  if b.Echo<Integer>(42) <> 42 then Halt(1);
  if b.Echo<string>('hi') <> 'hi' then Halt(2);
  b.Free;
end.
