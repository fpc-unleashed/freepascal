program inline_vars_in_repeat_until_01;

{$mode unleashed}

begin
  var n := 0;
  repeat
    var step := 3;
    n := n + step;
  until n >= 10;
  if n < 10 then halt(1);
  if n > 12 then halt(2);
end.
