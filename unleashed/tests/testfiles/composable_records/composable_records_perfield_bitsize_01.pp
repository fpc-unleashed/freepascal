program composable_records_perfield_bitsize_01;

{$mode unleashed}

type
  TBits = bitpacked record
    a: Byte bitsize 3;
    b: Byte bitsize 5;
  end;

begin
  { 3 + 5 = 8 bits = 1 byte }
  if SizeOf(TBits) <> 1 then halt(1);
end.
