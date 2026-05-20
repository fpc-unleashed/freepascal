program composable_records_wild_union_inside_union_01;

{$mode unleashed}

type
  TRec = packed record
    union size 4
      raw: LongWord;
      union size 4
        a: array[0..3] of Byte;
        b: array[0..1] of Word;
      end;
    end;
  end;

var
  r: TRec;
begin
  r.raw := $11223344;
  if r.a[0] <> $44 then halt(1);
  if r.b[0] <> $3344 then halt(2);
  if SizeOf(TRec) <> 4 then halt(3);
end.
