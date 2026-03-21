program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

begin
  if [1,2,3]=[1,2] then
    halt(1);
  WriteLn('ok');
end.
