program multi_var_init_inline_inferred_01;

{$mode unleashed}

begin
  var i, j := 10;
  if i <> 10 then halt(1);
  if j <> 10 then halt(2);

  var s1, s2 := 'hello';
  if s1 <> 'hello' then halt(3);
  if s2 <> 'hello' then halt(4);
end.
