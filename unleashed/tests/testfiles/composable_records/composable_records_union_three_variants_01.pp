program composable_records_union_three_variants_01;

{$mode unleashed}

type
  TRec = record
    union
      i32: LongWord;
      i16: array[0..1] of Word;
      i8:  array[0..3] of Byte;
    end;
  end;

var
  r: TRec;
begin
  r.i32 := $AABBCCDD;
  if r.i8[0] <> $DD then halt(1);
  if r.i8[3] <> $AA then halt(2);
  if r.i16[0] <> $CCDD then halt(3);
  if r.i16[1] <> $AABB then halt(4);
  if SizeOf(TRec) <> 4 then halt(5);
end.
