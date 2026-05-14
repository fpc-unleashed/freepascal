program backtick_multiline_01;

{$mode unleashed}

const
  banner =
`line1
line2
line3`;

begin
  // backtick form preserves embedded newlines verbatim
  if Pos('line1', banner) = 0 then halt(1);
  if Pos('line2', banner) = 0 then halt(2);
  if Pos('line3', banner) = 0 then halt(3);
end.
