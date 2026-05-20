{ %FAIL }
program composable_records_fail_duplicate_modifier_01;

{$mode unleashed}

type
  TRec = record size 4 size 8
    a: Byte;
  end;
begin
end.
