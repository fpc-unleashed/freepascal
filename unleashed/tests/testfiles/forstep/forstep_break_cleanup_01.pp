program forstep_break_cleanup_01;

{ break inside for-step exits cleanly without skipping cleanup }

{$mode unleashed}

var
  i, last, count : integer;

begin
  last:=-1;
  count:=0;
  for i:=1 to 100 step 7 do
    begin
      if i>30 then
        break;
      last:=i;
      inc(count);
    end;
  { last value reached before break: 1, 8, 15, 22, 29 -> last = 29, count = 5 }
  if (last<>29) or (count<>5) then
    halt(1);
end.
