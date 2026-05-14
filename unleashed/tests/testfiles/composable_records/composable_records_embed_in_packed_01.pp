program composable_records_embed_in_packed_01;

{$mode unleashed}

type
  TInner = packed record
    a, b: Byte;
  end;

  TOuter = packed record
    embed TInner;
    c: Byte;
  end;

var
  r: TOuter;
begin
  r.a := 1;
  r.b := 2;
  r.c := 3;
  if SizeOf(TOuter) <> 3 then halt(1);
  if r.a <> 1 then halt(2);
  if r.b <> 2 then halt(3);
  if r.c <> 3 then halt(4);
end.
