program forstep_step_context_keyword_01;

{ `step` is a context-sensitive keyword: only recognized between the
  to/downto expression and `do`. Anywhere else it stays an identifier. }

{$mode unleashed}

type
  TFoo = record
    step : integer;
  end;

var
  step : integer;
  i, sum : integer;
  foo : TFoo;

function step_func : integer;
begin
  result := 7;
end;

begin
  { `step` as variable name in unleashed mode }
  step := 3;
  if step<>3 then
    halt(1);

  { `step` as function name }
  if step_func<>7 then
    halt(2);

  { `step` as record field }
  foo.step := 99;
  if foo.step<>99 then
    halt(3);

  { `step` as variable used as upper bound -> consumed by hto, not a keyword }
  sum:=0;
  for i:=1 to step do
    sum:=sum+i;
  if sum<>6 then
    halt(4);

  { function call `step_func` as upper bound -> not a keyword either }
  sum:=0;
  for i:=1 to step_func do
    sum:=sum+i;
  if sum<>28 then
    halt(5);

  { mixing: `step` variable as upper bound AND `step` keyword in same loop }
  sum:=0;
  for i:=0 to step step 1 do  { upper = variable step (=3), keyword step = 1 }
    sum:=sum+i;
  if sum<>6 then  { 0+1+2+3 }
    halt(6);
end.
