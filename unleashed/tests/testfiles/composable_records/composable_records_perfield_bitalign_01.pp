program composable_records_perfield_bitalign_01;

{$mode unleashed}

type
  TBits = bitpacked record of Byte
    a: 3;
    b: 4 bitalign 8;          { align b to next byte boundary }
  end;

begin
  { a=3 bits + bitalign 8 pads to bit 8, b=4 bits = 12 bits = 2 bytes }
  if SizeOf(TBits) <> 2 then halt(1);
end.
