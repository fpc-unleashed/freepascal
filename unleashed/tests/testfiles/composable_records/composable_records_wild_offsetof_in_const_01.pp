program composable_records_wild_offsetof_in_const_01;

{$mode unleashed}

type
  TRec = packed record
    a: Byte;
    b: LongWord;
    c: Byte;
  end;

const
  OffA = OffsetOf(TRec.a);
  OffB = OffsetOf(TRec.b);
  OffC = OffsetOf(TRec.c);

begin
  { OffsetOf must fold to a compile-time constant }
  if OffA <> 0 then halt(1);
  if OffB <> 1 then halt(2);
  if OffC <> 5 then halt(3);
end.
