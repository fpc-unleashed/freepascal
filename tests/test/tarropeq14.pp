program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}

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
