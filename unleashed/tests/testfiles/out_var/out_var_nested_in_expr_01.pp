program out_var_nested_in_expr_01;
{$mode unleashed}

function f(out x: integer): integer;
begin
  x := 42;
  result := 100;
end;

begin
  // out-var declared from within a nested expression (the call result feeds
  // an inline-var initialiser); x must be visible afterwards
  var r := f(var x);
  if r <> 100 then Halt(1);
  if x <> 42 then Halt(2);
end.
