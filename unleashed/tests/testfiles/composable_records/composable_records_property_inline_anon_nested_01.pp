program composable_records_property_inline_anon_nested_01;

{$mode unleashed}

type
  TBaz = record
    record
      record
        Deep: LongInt;
      end;
    end;
    property D: LongInt read Deep write Deep;
  end;

var
  baz: TBaz;
begin
  baz.D := 7;
  if baz.Deep <> 7 then halt(1);
  baz.Deep := 11;
  if baz.D <> 11 then halt(2);
end.
