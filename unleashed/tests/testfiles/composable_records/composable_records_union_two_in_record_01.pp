program composable_records_union_two_in_record_01;

{$mode unleashed}

type
  TRec = packed record
    union size 4
      a: LongWord;
      ab: array[0..3] of Byte;
    end;
    union size 4
      b: LongWord;
      bb: array[0..3] of Byte;
    end;
  end;

var
  r: TRec;
begin
  r.a := $11223344;
  r.b := $AABBCCDD;
  if r.ab[0] <> $44 then halt(1);
  if r.bb[0] <> $DD then halt(2);
  if SizeOf(TRec) <> 8 then halt(3);
end.
