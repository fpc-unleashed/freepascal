program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}

type TIntArray = array of Integer;
function is1(constref arr: TIntArray): Boolean;
begin
  Result := arr = [1];
end;

begin
  if is1([]) then
    halt(1);
  WriteLn('ok');
end.
