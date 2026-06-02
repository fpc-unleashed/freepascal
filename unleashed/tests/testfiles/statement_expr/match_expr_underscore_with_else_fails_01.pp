{ %FAIL }
{ used to crash with EAccessViolation in append_else; now caught as
  a normal error - `_:` and a trailing `else` together are redundant }
program match_expr_underscore_with_else_fails_01;

{$mode unleashed}

procedure main;
begin
  var x := 33;
  var s := match x of
    0..4: 'one';
       _: 'wild';
  else 'fail';
  writeln(s);
end;

begin
  main;
end.
