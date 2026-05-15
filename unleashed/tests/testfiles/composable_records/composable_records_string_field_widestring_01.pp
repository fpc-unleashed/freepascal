program composable_records_string_field_widestring_01;

{$mode unleashed}

type
  TInner = record
    text: UnicodeString;
  end;
  TUnicode = record
    embed TInner;
    extra: Integer;
  end;

var
  u: TUnicode;
begin
  u.text := 'unicode text';
  u.extra := 7;
  if u.text <> 'unicode text' then halt(1);
  if u.extra <> 7 then halt(2);
end.
