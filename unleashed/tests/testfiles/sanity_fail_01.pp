{ %FAIL }
program sanity_fail_01;

{$mode unleashed}

begin
  // intentional syntax error: missing semicolon and bogus token
  this_should_not_parse @
end.
