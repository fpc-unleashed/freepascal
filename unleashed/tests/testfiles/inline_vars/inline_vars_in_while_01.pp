program inline_vars_in_while_01;

{$mode unleashed}

begin
  var n := 0;
  var iterations := 0;
  while n < 100 do
  begin
    var add := 7;
    n := n + add;
    Inc(iterations);
  end;
  if iterations <> 15 then halt(1);   // ceil(100/7) = 15
  if n          <> 105 then halt(2);  // 15 * 7
end.
