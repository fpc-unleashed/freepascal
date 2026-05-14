program backtick_lineending_cr_01;

{$mode unleashed}
{$MULTILINESTRINGLINEENDING CR}

const
  TWO_LINES =
`alpha
beta`;

begin
  var cr_count := 0;
  var lf_count := 0;
  for var c in TWO_LINES do
  begin
    if c = #13 then Inc(cr_count);
    if c = #10 then Inc(lf_count);
  end;
  if cr_count <> 1 then halt(1);
  if lf_count <> 0 then halt(2);
end.
