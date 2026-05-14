program triplequote_blank_lines_01;

{$mode unleashed}

const
  TEXT =
    '''
    line1

    line3
    ''';

begin
  // expect line1, blank, line3 (with platform line endings)
  if Pos('line1', TEXT) = 0 then halt(1);
  if Pos('line3', TEXT) = 0 then halt(2);
  // line break appears at least twice (line1 -> blank -> line3)
  var lf_count := 0;
  for var c in TEXT do
    if c = #10 then Inc(lf_count);
  if lf_count < 2 then halt(3);
end.
