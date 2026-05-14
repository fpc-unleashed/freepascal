program implicit_generics_function_01;

{$mode unleashed}
{$modeswitch implicitgenerics}

function Pick<T>(cond: Boolean; a, b: T): T;
begin
  if cond then Result := a else Result := b;
end;

begin
  if Pick<Integer>(true, 1, 2)   <> 1 then halt(1);
  if Pick<Integer>(false, 1, 2)  <> 2 then halt(2);
  if Pick<String>(true, 'a', 'b') <> 'a' then halt(3);
end.
