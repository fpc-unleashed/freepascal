program composable_records_record_bitsize_only_01;

{$mode unleashed}

type
  TBits = bitpacked record bitsize 16
    a, b: Byte;
  end;

begin
  { 16 bits = 2 bytes, matches payload exactly }
  if SizeOf(TBits) <> 2 then halt(1);
end.
