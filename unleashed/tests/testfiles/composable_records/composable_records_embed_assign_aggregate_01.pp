program composable_records_embed_assign_aggregate_01;

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
  r1, r2: TOuter;
begin
  r1.a := 10;
  r1.b := 20;
  r1.c := 30;
  r2 := r1;          { whole-record assignment copies the embed too }
  if r2.a <> 10 then halt(1);
  if r2.b <> 20 then halt(2);
  if r2.c <> 30 then halt(3);
end.
