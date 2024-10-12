program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}

function eq(const lhs,rhs: array of Integer): Boolean;
begin
  Result := lhs=rhs;
end;

begin
  if eq([1],[1,2]) then
    halt(1);
  WriteLn('ok');
end.
