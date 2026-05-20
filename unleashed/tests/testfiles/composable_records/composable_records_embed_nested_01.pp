program composable_records_embed_nested_01;

{$mode unleashed}

type
  TLeaf = record
    val: LongInt;
  end;

  TMid = record
    embed TLeaf;
    tag: Word;
  end;

  TTop = record
    embed TMid;
    extra: Byte;
  end;

var
  r: TTop;
begin
  r.val := 12345;
  r.tag := 7;
  r.extra := 99;
  if r.val <> 12345 then halt(1);
  if r.tag <> 7 then halt(2);
  if r.extra <> 99 then halt(3);
end.
