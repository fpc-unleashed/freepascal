program composable_records_method_cascade_embed_01;

{$mode unleashed}

type
  TLeaf = record
    val: LongInt;
    function Tripled: LongInt;
  end;

  TMid = record
    embed TLeaf;
    midflag: Byte;
  end;

  TTop = record
    embed TMid;
    topflag: Byte;
  end;

function TLeaf.Tripled: LongInt;
begin
  Result := val * 3;
end;

var
  t: TTop;
begin
  t.val := 5;
  t.midflag := 1;
  t.topflag := 2;
  if t.Tripled <> 15 then halt(1);
  if t.val <> 5 then halt(2);
  if t.midflag <> 1 then halt(3);
  if t.topflag <> 2 then halt(4);
end.
