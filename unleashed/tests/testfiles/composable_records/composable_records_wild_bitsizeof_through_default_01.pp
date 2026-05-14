program composable_records_wild_bitsizeof_through_default_01;

{$mode unleashed}

type
  TBits = bitpacked record of Boolean
    a, b, c, d: 1;
  end;

begin
  { each 1-bit Boolean field has BitSizeOf=1 }
  if BitSizeOf(TBits.a) <> 1 then halt(1);
  if BitSizeOf(TBits.b) <> 1 then halt(2);
  if BitSizeOf(TBits.d) <> 1 then halt(3);
end.
