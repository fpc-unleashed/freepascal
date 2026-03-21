program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

function eq(const lhs,rhs: array of Integer): Boolean;
begin
  Result := lhs=rhs;
end;

begin
  if not eq([1],[1]) then
    halt(1);
  WriteLn('ok');
end.
