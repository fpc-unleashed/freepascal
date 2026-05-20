program composable_records_record_bitalign_only_01;

{$mode unleashed}

type
  TBits = bitpacked record of Byte bitalign 16
    a: 1;
  end;

begin
  { bitalign 16 -> ceil(16/8) = 2 bytes alignment }
  if AlignOf(TBits) <> 2 then halt(1);
end.
