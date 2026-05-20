program composable_records_wild_pad_explicit_bits_01;

{$mode unleashed}

type
  TBits = bitpacked record of Boolean
    a: 1;
    pad 6;
    b: 1;
  end;

begin
  { 1 + 6 + 1 = 8 bits = 1 byte }
  if SizeOf(TBits) <> 1 then halt(1);
end.
