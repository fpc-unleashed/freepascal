program composable_records_bitpacked_bitalign_01;

{$mode unleashed}

type
  TBits = bitpacked record of Byte bitalign 32
    a: 8;
  end;

begin
  { bitalign 32 -> ceil(32/8) = 4 bytes recordalignment;
    payload is 1 byte but alignment is 4 }
  if AlignOf(TBits) <> 4 then halt(1);
end.
