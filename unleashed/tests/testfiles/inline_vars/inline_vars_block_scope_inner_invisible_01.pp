{ %FAIL }
program inline_vars_block_scope_inner_invisible_01;

{$mode unleashed}

begin
  begin
    var inner := 20;
  end;
  // inner not visible here
  WriteLn(inner);
end.
