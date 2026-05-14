program backtick_with_dollar_01;

{$mode unleashed}

const
  TEMPLATE = `Hello, $name $count`;

begin
  // unleashed backtick literals are NOT interpolated; $ stays literal.
  if TEMPLATE <> 'Hello, $name $count' then halt(1);
  if Pos('$', TEMPLATE) = 0 then halt(2);
end.
