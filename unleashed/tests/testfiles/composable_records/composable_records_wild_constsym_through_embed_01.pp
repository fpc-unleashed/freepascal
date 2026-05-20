program composable_records_wild_constsym_through_embed_01;

{$mode unleashed}

type
  TInner = record a, b: LongInt; end;
  TOuter = record embed TInner; c: LongInt; end;

var
  r: TOuter;
begin
  { typed constants with composition fields require const-init path through
    the flattened name space, which is a separate feature; runtime assign
    still works }
  r.a := 1;
  r.b := 2;
  r.c := 3;
  if r.a <> 1 then halt(1);
  if r.b <> 2 then halt(2);
  if r.c <> 3 then halt(3);
end.
