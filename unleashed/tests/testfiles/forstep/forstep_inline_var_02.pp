program forstep_inline_var_02;

{ inline var with step in mode unleashed }

{$mode unleashed}

var
  count, sum : integer;

begin
  count:=0;
  sum:=0;
  for var k:=5 to 50 step 5 do
    begin
      inc(count);
      sum:=sum+k;
    end;
  { 5,10,15,20,25,30,35,40,45,50 -> count = 10, sum = 275 }
  if (count<>10) or (sum<>275) then
    halt(1);
end.
