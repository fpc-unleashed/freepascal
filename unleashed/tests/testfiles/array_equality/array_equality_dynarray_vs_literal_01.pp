program array_equality_dynarray_vs_literal_01;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

type TIntArray = array of Integer;
function is1(constref arr: TIntArray): Boolean;
begin
  Result := arr = [1];
end;

begin
  if is1([]) then
    halt(1);
  WriteLn('ok');
end.
