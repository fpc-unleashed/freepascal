program forstep_continue_01;

{ continue inside a for-step body must skip the rest of the body and
  resume from the next stepped iteration, not loop forever }

{$mode unleashed}

var
  i, count, sum : integer;

begin
  { skip i = 25, expect 20 iterations out of 21 }
  count:=0;
  for i:=0 to 100 step 5 do
    begin
      if i=25 then
        continue;
      inc(count);
    end;
  if count<>20 then
    halt(1);

  { skip even i with step 1, expect odd sum 1+3+5+...+19 = 100 }
  sum:=0;
  for i:=1 to 20 step 1 do
    begin
      if (i mod 2)=0 then
        continue;
      sum:=sum+i;
    end;
  if sum<>100 then
    halt(2);

  { backward + continue: skip i = 11 in 20..1 step 3 -> 6 of 7 iterations }
  count:=0;
  for i:=20 downto 1 step 3 do
    begin
      if i=11 then
        continue;
      inc(count);
    end;
  if count<>6 then
    halt(3);
end.
