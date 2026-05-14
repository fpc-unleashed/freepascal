program backtick_lineending_platform_01;

{$mode unleashed}
{$MULTILINESTRINGLINEENDING PLATFORM}

const
  TWO_LINES =
`first
second`;

begin
  // PLATFORM = whatever LineEnding evaluates to at compile time
  if Pos(LineEnding, TWO_LINES) = 0 then halt(1);
  if Pos('first',  TWO_LINES) = 0 then halt(2);
  if Pos('second', TWO_LINES) = 0 then halt(3);
end.
