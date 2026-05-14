program composable_records_union_after_field_01;

{$mode unleashed}

type
  TRec = packed record
    header: LongWord;
    union of Byte size 4
      a: LongWord;
      b: array[0..3] of Byte;
    end;
  end;

var
  r: TRec;
begin
  r.header := $DEADBEEF;
  r.a := $01020304;
  if r.header <> $DEADBEEF then halt(1);
  if r.b[0] <> $04 then halt(2);
  if r.b[3] <> $01 then halt(3);
  if SizeOf(TRec) <> 8 then halt(4);
end.
