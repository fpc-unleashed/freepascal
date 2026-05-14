program for_counter_subrange_01;

{$mode unleashed}

type
  TDay = 1..7;

var
  d: TDay;

begin
  for d := 1 to 5 do
    ;
  if d <> 5 then halt(1);

  for d := 7 downto 1 do
    ;
  if d <> 1 then halt(2);
end.
