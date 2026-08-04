program array_equality_record_custom_operator_01;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

type
  tmyrec = record
    i: Integer;
  end;

operator =(const lhs,rhs:tmyrec): boolean;
begin
  Result:=lhs.i=rhs.i;
end;

function eq(const lhs,rhs: array of TMyRec): Boolean;
begin
  Result := lhs=rhs;
end;

var
  a,b:tmyrec;
begin
  a.i:=1;
  b.i:=1;
  if not eq([a], [b]) then
    Halt(1);
  WriteLn('Ok');
end.
