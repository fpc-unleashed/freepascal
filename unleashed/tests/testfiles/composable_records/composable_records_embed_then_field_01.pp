program composable_records_embed_then_field_01;

{$mode unleashed}

type
  TInner = record
    a: LongInt;
  end;

  TRec = record
    embed TInner;
    b: LongInt;
  end;

var
  r: TRec;
begin
  r.a := 100;
  r.b := 200;
  if r.a <> 100 then halt(1);
  if r.b <> 200 then halt(2);
end.
