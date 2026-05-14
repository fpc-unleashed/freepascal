program composable_records_embed_inline_anon_01;

{$mode unleashed}

type
  TRec = record
    record
      a, b: LongInt;
    end;
    c: Byte;
  end;

var
  r: TRec;
begin
  r.a := 7;
  r.b := 8;
  r.c := 9;
  if r.a <> 7 then halt(1);
  if r.b <> 8 then halt(2);
  if r.c <> 9 then halt(3);
end.
