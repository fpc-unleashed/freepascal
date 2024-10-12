{ %FAIL }
program Test;

{$Mode ObjFPC}{$H+}
{$modeswitch ArrayOperators}

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
