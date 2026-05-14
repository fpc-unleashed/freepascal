program backtick_escape_01;

{$mode unleashed}

const
  // doubled backtick produces a literal backtick inside the string
  s = `abc``def`;

begin
  if s <> 'abc`def' then halt(1);
  if Length(s) <> 7 then halt(2);
end.
