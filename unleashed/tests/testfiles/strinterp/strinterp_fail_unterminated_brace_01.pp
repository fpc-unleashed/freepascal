{ %FAIL }
program strinterp_fail_unterminated_brace_01;
// open `{` without matching `}` is a syntax error

{$mode unleashed}

var
  n: integer;
begin
  n := 42;
  writeln($'{n');
end.
