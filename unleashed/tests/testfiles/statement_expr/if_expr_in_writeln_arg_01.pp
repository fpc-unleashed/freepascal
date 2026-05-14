{ %NORUN }
program if_expr_in_writeln_arg_01;

{$mode unleashed}

begin
  // syntax-only: if-expression must be accepted as a Write/WriteLn arg
  for var i := 0 to 3 do
    WriteLn(if i mod 2 = 0 then 'even' else 'odd');
end.
