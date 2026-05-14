program if_expr_in_const_init_01;

{$mode unleashed}

const
  DEBUG_BUILD = false;

begin
  // if-expression in inline-var initializer at the top of begin..end
  var verbosity := if DEBUG_BUILD then 'verbose' else 'quiet';
  if verbosity <> 'quiet' then halt(1);

  var threshold := if DEBUG_BUILD then 0 else 100;
  if threshold <> 100 then halt(2);
end.
