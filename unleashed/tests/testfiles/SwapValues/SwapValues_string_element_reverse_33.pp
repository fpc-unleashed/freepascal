program SwapValues_string_element_reverse_33;
{$mode unleashed}
// swap loop with computed indexes reverses a string in place while an
// alias taken before the loop keeps the original contents
var
  s, alias: ansistring;
  n: integer;
begin
  s := 'abcdef';
  alias := s;
  n := Length(s);
  for var i := 1 to n shr 1 do
    SwapValues(s[i], s[n + 1 - i]);
  if s <> 'fedcba' then halt(1);
  if alias <> 'abcdef' then halt(2);
end.
