program composable_records_intrinsic_alignof_primitives_01;

{$mode unleashed}

begin
  if AlignOf(Byte)     <> 1 then halt(1);
  if AlignOf(Word)     <> 2 then halt(2);
  if AlignOf(LongWord) <> 4 then halt(3);
  if AlignOf(Int64)    <> 8 then halt(4);
  if AlignOf(Pointer)  <> SizeOf(Pointer) then halt(5);

  if BitAlignOf(Byte)     <> 8 then halt(6);
  if BitAlignOf(LongWord) <> 32 then halt(7);
  if BitAlignOf(Int64)    <> 64 then halt(8);
end.
