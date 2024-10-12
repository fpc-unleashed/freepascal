program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
type TIntArray = array of Integer;
function head(const arr: TIntArray): PInteger;
begin
  if [] = arr then
    Result := nil
  else Result := @arr[0];
end;

begin
  if head([]) <> nil then
    Halt(1);
  if head([1,2,3,4])^ <> 1 then
    Halt(1);
  WriteLn('ok');
end.
