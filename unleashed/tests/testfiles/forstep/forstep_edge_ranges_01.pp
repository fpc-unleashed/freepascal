program forstep_edge_ranges_01;

{ edge cases: step > range, step = 1 fold-back, empty ranges, from = to }

{$mode unleashed}

var
  i, count : integer;

begin
  { step larger than range -> body runs once at i = from }
  count:=0;
  for i:=1 to 5 step 100 do
    inc(count);
  if count<>1 then
    halt(1);

  { explicit step 1 must behave like a regular for loop }
  count:=0;
  for i:=1 to 5 step 1 do
    inc(count);
  if count<>5 then
    halt(2);

  { empty forward range }
  count:=0;
  for i:=10 to 1 step 2 do
    inc(count);
  if count<>0 then
    halt(3);

  { empty backward range }
  count:=0;
  for i:=1 downto 10 step 2 do
    inc(count);
  if count<>0 then
    halt(4);

  { from = to runs body exactly once }
  count:=0;
  for i:=5 to 5 step 3 do
    inc(count);
  if count<>1 then
    halt(5);
end.
