program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}

type TIntArray = array of Integer;
function isnot1(constref arr: TIntArray): Boolean;
begin
  Result := arr <> [1];
end;

begin
  if isnot1([1]) then
    halt(1);
  WriteLn('ok');
end.
