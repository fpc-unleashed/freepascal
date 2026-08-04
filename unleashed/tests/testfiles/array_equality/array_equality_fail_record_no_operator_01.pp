{ %FAIL }
program array_equality_fail_record_no_operator_01;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}
{$modeswitch ArrayEquality}

type
  tmyrec = record
    i: Integer;
  end;

function eq(const lhs,rhs: array of TMyRec): Boolean;
begin
  Result := lhs=rhs;
end;

begin
end.
