program SwapValues_self_noop_12;
{$mode unleashed}
// exchanging a variable with itself is a harmless no-op
var
  x: Integer;
  s: AnsiString;
begin
  x := 42;
  SwapValues(x, x);
  if x <> 42 then halt(1);
  s := 'self';
  SwapValues(s, s);
  if s <> 'self' then halt(2);
end.
