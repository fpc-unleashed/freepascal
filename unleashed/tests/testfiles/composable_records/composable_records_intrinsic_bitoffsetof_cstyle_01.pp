program composable_records_intrinsic_bitoffsetof_cstyle_01;

{$mode unleashed}

type
  TBits = bitpacked record of Boolean
    a, b, c: 1;
    d, e: 1;
  end;

begin
  if BitOffsetOf(TBits, a) <> 0 then halt(1);
  if BitOffsetOf(TBits, c) <> 2 then halt(2);
  if BitOffsetOf(TBits, e) <> 4 then halt(3);
end.
