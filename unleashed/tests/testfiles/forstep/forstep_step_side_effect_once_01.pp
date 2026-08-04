program forstep_step_side_effect_once_01;

{ step expression evaluated once, even when it has side effects }

{$mode unleashed}

var
  i, count, calls : integer;

function getstep : integer;
begin
  inc(calls);
  result:=3;
end;

begin
  calls:=0;
  count:=0;
  for i:=0 to 12 step getstep do
    inc(count);
  if (count<>5) or (calls<>1) then
    halt(1);
end.
