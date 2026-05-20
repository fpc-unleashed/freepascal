program composable_records_intrinsic_offsetof_through_multi_embed_01;

{$mode unleashed}

type
  TA = packed record
    a1, a2: Byte;
  end;

  TB = packed record
    embed TA;
    b1: Byte;
  end;

  TC = packed record
    embed TB;
    c1: Byte;
  end;

begin
  { OffsetOf must walk the chain through two embed carriers }
  if OffsetOf(TC.a1) <> 0 then halt(1);
  if OffsetOf(TC.a2) <> 1 then halt(2);
  if OffsetOf(TC.b1) <> 2 then halt(3);
  if OffsetOf(TC.c1) <> 3 then halt(4);
end.
