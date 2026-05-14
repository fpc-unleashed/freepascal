program composable_records_wild_with_for_in_01;

{$mode unleashed}

type
  TInner = record a: LongInt; end;
  TOuter = record embed TInner; b: LongInt; end;

var
  arr: array[0..3] of TOuter;
  sum: LongInt;
  it: TOuter;
begin
  arr[0].a := 1; arr[0].b := 10;
  arr[1].a := 2; arr[1].b := 20;
  arr[2].a := 3; arr[2].b := 30;
  arr[3].a := 4; arr[3].b := 40;
  sum := 0;
  for it in arr do
    sum := sum + it.a + it.b;
  if sum <> 1+2+3+4 + 10+20+30+40 then halt(1);
end.
