program composable_records_bitpacked_bitsize_01;

{$mode unleashed}

type
  TBits = bitpacked record of Byte bitsize 12
    a, b, c, d: 3;     { 12 bits total }
  end;

begin
  { bitsize 12 -> ceil(12/8) = 2 bytes }
  if SizeOf(TBits) <> 2 then halt(1);
end.
