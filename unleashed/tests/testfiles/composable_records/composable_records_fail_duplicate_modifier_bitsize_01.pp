{ %FAIL }
program composable_records_fail_duplicate_modifier_bitsize_01;

{$mode unleashed}

type
  TRec = bitpacked record of Byte bitsize 8 bitsize 16
    a: 1;
  end;
begin
end.
