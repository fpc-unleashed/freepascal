program composable_records_string_field_shortstring_01;

{$mode unleashed}

type
  TLabel = record
    record
      tag: ShortString;
    end;
    code: Integer;
  end;

var
  l: TLabel;
begin
  l.tag := 'hello';
  l.code := 42;
  if l.tag <> 'hello' then halt(1);
  if Length(l.tag) <> 5 then halt(2);
  if l.code <> 42 then halt(3);
end.
