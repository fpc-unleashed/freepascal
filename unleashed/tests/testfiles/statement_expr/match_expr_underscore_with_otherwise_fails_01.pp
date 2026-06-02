{ %FAIL }
{ same redundancy check as the `else` variant but with `otherwise` }
program match_expr_underscore_with_otherwise_fails_01;

{$mode unleashed}

procedure main;
begin
  var x := 33;
  var s := match x of
    0..4: 'one';
       _: 'wild';
  otherwise 'fail';
  writeln(s);
end;

begin
  main;
end.
