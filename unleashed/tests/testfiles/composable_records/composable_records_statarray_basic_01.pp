program composable_records_statarray_basic_01;

{$mode unleashed}

type
  TBase = record
    x: Integer;
  end;
  TDerived = record
    embed TBase;
    y: Integer;
  end;

var
  arr: array[0..2] of TDerived;
  i: Integer;
  total: Integer;
begin
  for i := 0 to 2 do
    begin
      arr[i].x := i + 1;
      arr[i].y := (i + 1) * 10;
    end;
  total := 0;
  for i := 0 to 2 do
    total := total + arr[i].x + arr[i].y;
  if total <> (1+2+3) + (10+20+30) then halt(1);
end.
