{ %FAIL }
program composable_records_fail_record_exceeds_bitsize_01;

{$mode unleashed}

type
  TBits = bitpacked record of Boolean bitsize 4
    a, b, c, d, e: 1;      { 5 bits exceeds declared bitsize 4 }
  end;
begin
end.
