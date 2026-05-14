program composable_records_generic_with_embed_01;

{$mode unleashed}

type
  THeader = record
    magic: LongWord;
  end;

  { generic record can compose - the embed target is a concrete type,
    not the generic parameter, which is fine }
  generic TFramed<T> = record
    embed THeader;
    payload: T;
  end;

var
  f: specialize TFramed<LongInt>;
begin
  f.magic := $CAFEBABE;
  f.payload := 99;
  if f.magic <> $CAFEBABE then halt(1);
  if f.payload <> 99 then halt(2);
end.
