program composable_records_bitpacked_pad_zero_01;

{$mode unleashed}

type
  TBits = bitpacked record of Byte
    a: 3;
    pad 0;             { align to next Byte boundary }
    b: 8;
  end;

begin
  { a=3 bits + pad-to-8 (5 bits) + b=8 bits = 16 bits = 2 bytes }
  if SizeOf(TBits) <> 2 then halt(1);
end.
