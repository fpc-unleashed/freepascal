program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

type TIntArray = array of Integer;
function eq(const lhs,rhs: TIntArray): Boolean;
begin
  Result := lhs=rhs;
end;

begin
  if eq([1],[1,2]) then
    halt(1);
  WriteLn('ok');
end.
