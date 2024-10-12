program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}

function head(constref arr: array of Integer): PInteger;
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
