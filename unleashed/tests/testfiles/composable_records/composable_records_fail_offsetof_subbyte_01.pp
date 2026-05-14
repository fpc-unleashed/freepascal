{ %FAIL }
program composable_records_fail_offsetof_subbyte_01;

{$mode unleashed}

type
  TBits = bitpacked record of Byte
    a, b, c: 1;
  end;
begin
  { byte-precise OffsetOf cannot represent a sub-byte field }
  if OffsetOf(TBits.b) = 0 then ;
end.
