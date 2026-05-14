program if_expr_basic_01;

{$mode unleashed}

begin
  var a := 5;
  var s := if a > 0 then 'positive' else 'non-positive';
  if s <> 'positive' then halt(1);

  a := -3;
  s := if a > 0 then 'positive' else 'non-positive';
  if s <> 'non-positive' then halt(2);
end.
