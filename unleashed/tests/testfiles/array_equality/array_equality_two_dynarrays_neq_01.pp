program array_equality_two_dynarrays_neq_01;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

type TIntArray = array of Integer;
function neq(const lhs,rhs: TIntArray): Boolean;
begin
  Result := lhs<>rhs;
end;

begin
  if neq([1],[1]) then
    halt(1);
  WriteLn('ok');
end.
