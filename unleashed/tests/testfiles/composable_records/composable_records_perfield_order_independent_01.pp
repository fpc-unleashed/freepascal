program composable_records_perfield_order_independent_01;

{$mode unleashed}

type
  TBits = bitpacked record
    a: Byte size 2 bitsize 3;        { 3 bits, slot widened to 2 bytes }
  end;

  TBits2 = bitpacked record
    a: Byte bitsize 3 size 2;        { same modifiers, opposite order }
  end;

begin
  if SizeOf(TBits) <> SizeOf(TBits2) then halt(1);
end.
