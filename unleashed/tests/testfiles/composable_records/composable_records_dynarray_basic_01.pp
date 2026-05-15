program composable_records_dynarray_basic_01;

{$mode unleashed}

type
  TBase = record
    x, y: Integer;
  end;
  TDerived = record
    embed TBase;
    z: Integer;
  end;

var
  arr: array of TDerived;
  i: Integer;
begin
  SetLength(arr, 4);
  for i := 0 to 3 do
    begin
      arr[i].x := i * 10;
      arr[i].y := i * 20;
      arr[i].z := i * 30;
    end;
  for i := 0 to 3 do
    begin
      if arr[i].x <> i * 10 then halt(1);
      if arr[i].y <> i * 20 then halt(2);
      if arr[i].z <> i * 30 then halt(3);
    end;
end.
