program array_equality_nested_arrays_01;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

type TIntArray = array of integer;
function eq(const lhs,rhs: array of TIntArray): Boolean;
begin
  Result := lhs=rhs;
end;

begin
  if not eq([[1,2],[3,4]], [[1,2],[3,4]]) then
    Halt(1);
  WriteLn('Ok');
end.
