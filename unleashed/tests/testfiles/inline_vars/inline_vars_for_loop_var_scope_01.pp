{ %FAIL }
program inline_vars_for_loop_var_scope_01;

{$mode unleashed}

begin
  for var i := 0 to 9 do
    ;
  // i not visible after loop
  WriteLn(i);
end.
