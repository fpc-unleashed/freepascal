program array_equality_dynarray_neq_literal_01;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

type TIntArray = array of Integer;
function isnot1(constref arr: TIntArray): Boolean;
begin
  Result := arr <> [1];
end;

begin
  if isnot1([1]) then
    halt(1);
  WriteLn('ok');
end.
