program composable_records_embed_basic_01;

{$mode unleashed}

type
  TInner = record
    a, b: LongInt;
  end;

  TOuter = record
    embed TInner;
    c: LongInt;
  end;

var
  r: TOuter;
begin
  r.a := 1;
  r.b := 2;
  r.c := 3;
  if r.a <> 1 then halt(1);
  if r.b <> 2 then halt(2);
  if r.c <> 3 then halt(3);
  if SizeOf(TOuter) <> 12 then halt(4);
end.
