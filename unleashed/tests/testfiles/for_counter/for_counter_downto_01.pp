program for_counter_downto_01;

{$mode unleashed}

var
  i: Integer;

begin
  for i := 10 downto 1 do
    ;
  // downto natural exit: counter holds the lower bound
  if i <> 1 then halt(1);
end.
