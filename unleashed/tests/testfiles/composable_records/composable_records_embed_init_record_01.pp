program composable_records_embed_init_record_01;

{$mode unleashed}

type
  TInner = record
    x, y: LongInt;
  end;

  TOuter = record
    embed TInner;
    name: ShortString;
  end;

var
  r: TOuter;
begin
  r.x := -5;
  r.y := 11;
  r.name := 'pt';
  if r.x <> -5 then halt(1);
  if r.y <> 11 then halt(2);
  if r.name <> 'pt' then halt(3);
end.
