program composable_records_wild_pad_zero_then_field_01;

{$mode unleashed}

type
  TBits = bitpacked record of Byte
    a: 3;
    pad 0;          { snap to next Byte boundary }
    b: 8;
    pad 0;          { already aligned, no-op }
    c: 1;
  end;

begin
  { 3 + pad-to-8 (5 bits) + 8 + pad-noop + 1 = 17 bits -> 3 bytes }
  if SizeOf(TBits) <> 3 then halt(1);
end.
