program composable_records_embed_two_distinct_01;

{$mode unleashed}

type
  TA = record a: Byte; end;
  TB = record b: Byte; end;

  TRec = record
    embed TA;
    embed TB;
    c: Byte;
  end;

var
  r: TRec;
begin
  r.a := 10;
  r.b := 20;
  r.c := 30;
  if r.a <> 10 then halt(1);
  if r.b <> 20 then halt(2);
  if r.c <> 30 then halt(3);
end.
