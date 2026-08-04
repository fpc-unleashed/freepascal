{ %FAIL }
{ This test must FAIL to compile - for-loop var must not be visible after the loop }
{$mode unleashed}
program inline_vars_fail_for_var_after_loop_01;

begin
  for var i := 1 to 3 do ;
  WriteLn(i); { ERROR: i is out of scope here }
end.
