program array_equality_openarray_neq_literal_01;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

function isnot1(constref arr: array of Integer): Boolean;
begin
  Result := arr <> [1];
end;

begin
  if isnot1([1]) then
    halt(1);
  WriteLn('ok');
end.
