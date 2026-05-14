program composable_records_intrinsic_bitalignof_01;

{$mode unleashed}

type
  TBits = bitpacked record of Byte
    a: 8;
    b: 8 bitalign 16;
  end;

begin
  if BitAlignOf(TBits.b) <> 16 then halt(1);
end.
