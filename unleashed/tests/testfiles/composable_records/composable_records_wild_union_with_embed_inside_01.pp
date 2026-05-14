program composable_records_wild_union_with_embed_inside_01;

{$mode unleashed}

type
  TPos = record
    x, y: LongInt;
  end;

  TVel = record
    vx, vy: LongInt;
  end;

  TRec = record
    union
      embed TPos;
      embed TVel;
    end;
  end;

var
  r: TRec;
begin
  { both embeds overlay the same 8 bytes }
  r.x := $11111111;
  r.y := $22222222;
  if r.vx <> $11111111 then halt(1);
  if r.vy <> $22222222 then halt(2);
end.
