program composable_records_wild_packed_inline_anon_01;

{$mode unleashed}

type
  { plain inline anonymous `record` at top of a record body - the
    fields flatten into the surrounding record's name space }
  TRec = record
    record
      a, b, c: Byte;
    end;
    tail: LongInt;
  end;

var
  r: TRec;
begin
  r.a := 1;
  r.b := 2;
  r.c := 3;
  r.tail := 42;
  if r.a + r.b + r.c <> 6 then halt(1);
  if r.tail <> 42 then halt(2);
end.
