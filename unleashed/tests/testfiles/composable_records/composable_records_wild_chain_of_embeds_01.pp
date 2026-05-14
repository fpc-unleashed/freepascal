program composable_records_wild_chain_of_embeds_01;

{$mode unleashed}

type
  TA = record va: Byte; end;
  TB = record vb: Byte; end;
  TC = record vc: Byte; end;
  TD = record vd: Byte; end;
  TE = record ve: Byte; end;

  TFull = packed record
    embed TA;
    embed TB;
    embed TC;
    embed TD;
    embed TE;
    extra: Byte;
  end;

var
  r: TFull;
begin
  r.va := 1;
  r.vb := 2;
  r.vc := 3;
  r.vd := 4;
  r.ve := 5;
  r.extra := 99;
  if r.va <> 1 then halt(1);
  if r.vb <> 2 then halt(2);
  if r.vc <> 3 then halt(3);
  if r.vd <> 4 then halt(4);
  if r.ve <> 5 then halt(5);
  if r.extra <> 99 then halt(6);
  if SizeOf(TFull) <> 6 then halt(7);
end.
