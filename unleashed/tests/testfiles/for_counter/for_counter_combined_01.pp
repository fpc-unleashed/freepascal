program for_counter_combined_01;

{ unleashed mode: the for-loop counter keeps its last value after the loop
  exits, both for natural exit and for break }

{$mode unleashed}

var
  i, j : integer;

begin
  { classic for loop, natural exit -> i must equal `to` }
  for i:=1 to 10 do ;
  if i<>10 then
    halt(1);

  for i:=10 downto 1 do ;
  if i<>1 then
    halt(2);

  { classic for loop, break -> i keeps the value at break time }
  for i:=1 to 100 do
    if i=7 then break;
  if i<>7 then
    halt(3);

  { downto + break }
  for i:=50 downto 0 do
    if i=42 then break;
  if i<>42 then
    halt(4);

  { from = to (single iteration) -> i = to }
  for i:=5 to 5 do ;
  if i<>5 then
    halt(5);

  { empty range -> body never runs, i keeps the from value (initialised but
    not iterated) }
  for i:=10 to 1 do
    halt(6);

  { nested loops both preserve their counters }
  for i:=1 to 3 do
    for j:=100 to 105 do ;
  if (i<>3) or (j<>105) then
    halt(7);
end.
