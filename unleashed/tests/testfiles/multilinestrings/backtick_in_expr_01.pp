program backtick_in_expr_01;

{$mode unleashed}

begin
  var name := 'world';
  var s := `Hello, ` + name + `!`;
  if s <> 'Hello, world!' then halt(1);
end.
