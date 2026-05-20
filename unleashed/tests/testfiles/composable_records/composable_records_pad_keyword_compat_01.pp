program composable_records_pad_keyword_compat_01;

{$mode unleashed}

type
  { 'pad' is contextual; when used as a regular field name outside the
    bitpacked-with-default-type context it must keep parsing }
  TRec = record
    pad: LongInt;
    other: Byte;
  end;

var
  r: TRec;
begin
  r.pad := 42;
  r.other := 7;
  if r.pad <> 42 then halt(1);
  if r.other <> 7 then halt(2);
end.
