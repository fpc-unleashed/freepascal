program SwapValues_shortstring_element_31;
{$mode unleashed}
// shortstring element operands: plain in-place exchange
var
  s: shortstring;
  i, j: integer;
begin
  s := 'abcd';
  i := 2; j := 3;
  SwapValues(s[i], s[j]);
  if s <> 'acbd' then halt(1);
end.
