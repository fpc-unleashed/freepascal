program composable_records_intrinsic_offsetof_through_embed_01;

{$mode unleashed}

type
  TInner = packed record
    a, b: Byte;
  end;

  TOuter = packed record
    leader: Word;
    embed TInner;
  end;

begin
  if OffsetOf(TOuter.leader) <> 0 then halt(1);
  if OffsetOf(TOuter.a)      <> 2 then halt(2);
  if OffsetOf(TOuter.b)      <> 3 then halt(3);
end.
