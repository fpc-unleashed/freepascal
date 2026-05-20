program composable_records_wild_array_of_record_01;

{$mode unleashed}

type
  TInner = record a: Byte; end;
  TOuter = record
    embed TInner;
    b: Byte;
  end;

var
  arr: array[0..2] of TOuter;
  i: Integer;
begin
  for i := 0 to 2 do
    begin
      arr[i].a := Byte(i);
      arr[i].b := Byte(i + 10);
    end;
  if arr[0].a <> 0 then halt(1);
  if arr[2].a <> 2 then halt(2);
  if arr[1].b <> 11 then halt(3);
end.
