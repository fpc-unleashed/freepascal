program array_equality_two_openarrays_neq_01;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

function neq(const lhs,rhs: array of Integer): Boolean;
begin
  Result := lhs<>rhs;
end;

begin
  if neq([1],[1]) then
    halt(1);
  WriteLn('ok');
end.
