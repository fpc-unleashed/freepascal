{ %FAIL }
program out_var_fail_untyped_discard_01;
{$mode unleashed}

procedure grab(var buf);
begin
end;

begin
  // the discard's hidden temp needs a type too
  grab(_);
end.
