program composable_records_bitpacked_with_byte_field_01;

{$mode unleashed}

type
  TBits = bitpacked record of Boolean
    a, b, c: 1;
    k: Byte;            { regular field within bitpacked }
    p, q: 1;
  end;

begin
  { 3 + 8 + 2 = 13 bits, rounded to 2 bytes }
  if SizeOf(TBits) >= 1 then ;     { just check it compiles cleanly }
end.
