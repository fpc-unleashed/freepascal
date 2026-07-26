program SwapValues_string_element_char_32;
{$mode unleashed}
// ansistring element paired with a plain char variable
var
  s, alias: ansistring;
  c: char;
begin
  s := 'abcd';
  alias := s;
  c := 'z';
  SwapValues(s[1], c);
  if s <> 'zbcd' then halt(1);
  if c <> 'a' then halt(2);
  if alias <> 'abcd' then halt(3);
end.
