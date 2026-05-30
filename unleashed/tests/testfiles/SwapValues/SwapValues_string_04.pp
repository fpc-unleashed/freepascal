program SwapValues_string_04;
{$mode unleashed}
var
  s, t: AnsiString;
begin
  s := 'hello'; t := 'world';
  SwapValues(s, t);
  if s <> 'world' then halt(1);
  if t <> 'hello' then halt(2);
end.
