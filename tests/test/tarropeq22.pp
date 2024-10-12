program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}

function isnot1(constref arr: array of Integer): Boolean;
begin
  Result := arr <> [1];
end;

begin
  if isnot1([1]) then
    halt(1);
  WriteLn('ok');
end.
