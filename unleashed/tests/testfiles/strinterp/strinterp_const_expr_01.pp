program strinterp_const_expr_01;

{$mode unleashed}

var
  s: string;
begin
  // literal-only placeholders compile to a single string at runtime
  s := $'{1 + 2} = {3}';
  if s <> '3 = 3' then halt(1);

  // mixing literal and variable
  s := $'{42}+{1}';
  if s <> '42+1' then halt(2);
end.
