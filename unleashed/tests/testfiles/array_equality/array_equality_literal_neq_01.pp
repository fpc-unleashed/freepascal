program array_equality_literal_neq_01;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

begin
  if [1,2,3]<>[1,2,3] then
    halt(1);
  WriteLn('ok');
end.
