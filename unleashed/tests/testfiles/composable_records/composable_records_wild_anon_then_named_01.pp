program composable_records_wild_anon_then_named_01;

{$mode unleashed}

type
  TRec = record
    record
      x, y: LongInt;       { flattened anonymous }
    end;
    named: record           { regular named sub-record - NOT flattened }
      a: Byte;
    end;
  end;

var
  r: TRec;
begin
  r.x := 1;
  r.y := 2;
  r.named.a := 3;
  if r.x <> 1 then halt(1);
  if r.y <> 2 then halt(2);
  if r.named.a <> 3 then halt(3);
end.
