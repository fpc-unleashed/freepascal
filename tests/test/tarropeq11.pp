program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}

function neq(const lhs,rhs: array of Integer): Boolean;
begin
  Result := lhs<>rhs;
end;

begin
  if neq([1],[1]) then
    halt(1);
  WriteLn('ok');
end.
