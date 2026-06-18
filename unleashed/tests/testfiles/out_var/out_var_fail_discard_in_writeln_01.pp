{ %FAIL }
program out_var_fail_discard_in_writeln_01;
{$mode unleashed}

// intrinsics have no out parameters, so `_` is not a discard there;
// with no `_` in scope this is an unknown identifier
begin
  writeln(_);
end.
