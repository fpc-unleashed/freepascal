{ %FAIL }
program composable_records_fail_size_bitsize_mutex_01;

{$mode unleashed}

type
  TRec = bitpacked record of Byte size 4 bitsize 16
    a: 1;
  end;
begin
end.
