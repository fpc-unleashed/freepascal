{ %FAIL }
program composable_records_fail_union_exceeds_bitsize_01;

{$mode unleashed}

type
  TRec = packed record
    union of Byte bitsize 4
      a: bitpacked record of Byte
        x: 8;             { 8 bits exceeds declared bitsize 4 }
      end;
    end;
  end;
begin
end.
