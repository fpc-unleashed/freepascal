program backtick_lineending_lf_01;

{$mode unleashed}
{$MULTILINESTRINGLINEENDING LF}

const
  THREE_LINES =
`a
b
c`;

begin
  // every newline embedded as LF only (no CR)
  for var c in THREE_LINES do
    if c = #13 then halt(1);
  // exactly 2 LFs in the literal
  var n := 0;
  for var c in THREE_LINES do
    if c = #10 then Inc(n);
  if n <> 2 then halt(2);
end.
