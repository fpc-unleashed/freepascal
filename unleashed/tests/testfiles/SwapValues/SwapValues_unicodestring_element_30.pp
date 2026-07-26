program SwapValues_unicodestring_element_30;
{$mode unleashed}
// unicodestring element operands with copy-on-write kept intact
var
  s, alias: unicodestring;
  i, j: integer;
begin
  s := 'abcd';
  alias := s;
  i := 1; j := 4;
  SwapValues(s[i], s[j]);
  if s <> 'dbca' then halt(1);
  if alias <> 'abcd' then halt(2);
end.
