program inline_vars_block_scope_01;

{$mode unleashed}

begin
  var outer := 10;
  begin
    var inner := 20;
    if inner <> 20 then halt(1);
    if outer <> 10 then halt(2);
  end;
  if outer <> 10 then halt(3);
end.
