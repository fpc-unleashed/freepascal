program composable_records_perfield_order_independent_01;

{$mode unleashed}

type
  TBits = bitpacked record
    a: Byte align 4 bitsize 3;       { 3 bits, on a 4-byte alignment boundary }
  end;

  TBits2 = bitpacked record
    a: Byte bitsize 3 align 4;       { same modifiers, opposite order }
  end;

begin
  if SizeOf(TBits) <> SizeOf(TBits2) then halt(1);
end.
