program backtick_trim_left_all_01;

{$mode unleashed}
{$MULTILINESTRINGTRIMLEFT ALL}

const
  CLEAN =
`    line1
        line2
              line3`;

begin
  // ALL strips every leading whitespace from every line
  if Pos(' ', CLEAN) <> 0 then halt(1);   // no leading spaces survive
  if Pos('line1', CLEAN) = 0 then halt(2);
  if Pos('line2', CLEAN) = 0 then halt(3);
end.
