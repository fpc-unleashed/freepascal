program forstep_plain_for_regression_01;

{ regression: regular for loops without step still work in mode unleashed }

{$mode unleashed}

var
  i, count : integer;

begin
  count:=0;
  for i:=1 to 10 do
    inc(count);
  if count<>10 then
    halt(1);

  count:=0;
  for i:=10 downto 1 do
    inc(count);
  if count<>10 then
    halt(2);
end.
