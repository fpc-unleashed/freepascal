program array_equality_literal_eq_01;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

begin
  if not ([1,2,3]=[1,2,3]) then
    halt(1);
  WriteLn('ok');
end.
