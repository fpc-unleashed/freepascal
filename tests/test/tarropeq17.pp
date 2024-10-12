program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}

begin
  if not ([1,2,3]=[1,2,3]) then
    halt(1);
  WriteLn('ok');
end.
