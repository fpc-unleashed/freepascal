program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}

begin
  if [1,2,3]<>[1,2,3] then
    halt(1);
  WriteLn('ok');
end.
