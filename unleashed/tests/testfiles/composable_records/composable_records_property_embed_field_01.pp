program composable_records_property_embed_field_01;

{$mode unleashed}

type
  TBase = record
    Value: LongInt;
  end;

  TBar = record
    embed TBase;
    property Val: LongInt read Value write Value;
  end;

var
  bar: TBar;
begin
  bar.Val := 42;
  if bar.Value <> 42 then halt(1);
  bar.Value := 7;
  if bar.Val <> 7 then halt(2);
end.
