program array_concat_dynamic_growth_01;

{$mode unleashed}

begin
  var a: array of Integer := nil;
  for var i := 1 to 100 do
    a := a + [i];
  if Length(a) <> 100 then halt(1);
  if a[0]      <> 1   then halt(2);
  if a[99]     <> 100 then halt(3);

  var sum := 0;
  for var x in a do
    sum := sum + x;
  if sum <> 5050 then halt(4);
end.
