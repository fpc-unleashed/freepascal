{ %FAIL }
program inline_vars_eq_form_rejected_01;

{$mode unleashed}

begin
  // inline var must use `:=`, never `=` (that form is for classic var section)
  var x: Integer = 42;
  WriteLn(x);
end.
