program composable_records_intrinsic_bitoffsetof_01;

{$mode unleashed}

type
  TBits = bitpacked record of Byte
    a, b, c: 1;
    k: 5;
  end;

begin
  if BitOffsetOf(TBits.a) <> 0 then halt(1);
  if BitOffsetOf(TBits.b) <> 1 then halt(2);
  if BitOffsetOf(TBits.c) <> 2 then halt(3);
  if BitOffsetOf(TBits.k) <> 3 then halt(4);
end.
