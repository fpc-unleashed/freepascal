program SwapValues_string_element_29;
{$mode unleashed}
// ansistring element operands: constant and variable indexes, self swap,
// and copy-on-write: a swap in place must not touch an aliased string
var
  s, alias: ansistring;
  i, j: integer;
begin
  s := 'abcd';
  i := 1;
  SwapValues(s[i], s[i]);
  if s <> 'abcd' then halt(1);
  SwapValues(s[1], s[2]);
  if s <> 'bacd' then halt(2);
  i := 1; j := 2;
  SwapValues(s[i], s[j]);
  if s <> 'abcd' then halt(3);
  alias := s;
  SwapValues(s[1], s[4]);
  if s <> 'dbca' then halt(4);
  if alias <> 'abcd' then halt(5);
end.
