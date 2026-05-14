program backtick_lineending_crlf_01;

{$mode unleashed}
{$MULTILINESTRINGLINEENDING CRLF}

const
  TWO_LINES =
`first
second`;

begin
  // expect CRLF embedded for the one newline; check by counting
  var cr_count := 0;
  var lf_count := 0;
  for var c in TWO_LINES do
  begin
    if c = #13 then Inc(cr_count);
    if c = #10 then Inc(lf_count);
  end;
  if cr_count <> 1 then halt(1);
  if lf_count <> 1 then halt(2);
end.
