program forstep_basic_fwd_back_01;

{ basic forward and backward step }

{$mode unleashed}

var
  i, count, sum : integer;

begin
  count:=0;
  sum:=0;
  for i:=1 to 10 step 2 do
    begin
      inc(count);
      sum:=sum+i;
    end;
  if (count<>5) or (sum<>25) then
    halt(1);

  count:=0;
  sum:=0;
  for i:=20 downto 1 step 3 do
    begin
      inc(count);
      sum:=sum+i;
    end;
  if (count<>7) or (sum<>77) then
    halt(2);
end.
