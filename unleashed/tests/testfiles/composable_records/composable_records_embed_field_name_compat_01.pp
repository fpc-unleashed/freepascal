program composable_records_embed_field_name_compat_01;

{$mode unleashed}

type
  { keyword 'embed' must still parse as a field name when followed by ':' }
  TRec = record
    embed: LongInt;
    other: Byte;
  end;

var
  r: TRec;
begin
  r.embed := 1234;
  r.other := 56;
  if r.embed <> 1234 then halt(1);
  if r.other <> 56 then halt(2);
end.
