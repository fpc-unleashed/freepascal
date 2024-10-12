program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}

type TIntArray = array of integer;
function eq(const lhs,rhs: array of TIntArray): Boolean;
begin
  Result := lhs=rhs;
end;

begin
  if eq([[1,2],[3]], [[1],[3,4]]) then
    Halt(1);
  WriteLn('Ok');
end.
