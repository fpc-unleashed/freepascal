program composable_records_embed_size_layout_01;

{$mode unleashed}

type
  TInner = packed record
    a, b, c: Byte;
  end;

  TOuter = packed record
    embed TInner;
    d, e: Byte;
  end;

begin
  { embed is a transparent flatten: storage of TInner sits at offset 0,
    d/e immediately after }
  if SizeOf(TInner) <> 3 then halt(1);
  if SizeOf(TOuter) <> 5 then halt(2);
end.
