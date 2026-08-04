program array_equality_openarray_vs_literal_02;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

function is1(constref arr: array of Integer): Boolean;
begin
  Result := arr = [1];
end;

begin
  if is1([]) then
    halt(1);
  WriteLn('ok');
end.
