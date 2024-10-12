program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}

function is1(constref arr: array of Integer): Boolean;
begin
  Result := arr = [1];
end;

begin
  if is1([]) then
    halt(1);
  WriteLn('ok');
end.
