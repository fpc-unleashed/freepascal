{ %FAIL }
program composable_records_fail_of_after_modifier_01;

{$mode unleashed}

type
  TRec = bitpacked record size 4 of Byte
    a: 1;
  end;
begin
end.
