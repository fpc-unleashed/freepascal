program composable_records_dynarray_for_in_01;

{$mode unleashed}

type
  TPair = record
    record
      a, b: Integer;
    end;
    sum: Integer;
  end;

var
  arr: array of TPair;
  p: TPair;
  total: Integer;
begin
  SetLength(arr, 3);
  arr[0].a := 1; arr[0].b := 2; arr[0].sum := 3;
  arr[1].a := 4; arr[1].b := 5; arr[1].sum := 9;
  arr[2].a := 7; arr[2].b := 8; arr[2].sum := 15;
  total := 0;
  for p in arr do
    total := total + p.sum;
  if total <> 27 then halt(1);
  total := 0;
  for p in arr do
    total := total + p.a + p.b;
  if total <> 27 then halt(2);
end.
