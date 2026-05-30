program SwapValues_string_loop_05;
{$mode unleashed}
// the swap is refcount-neutral, so many iterations neither leak nor double-free
var
  s, t: AnsiString;
  i: Integer;
begin
  s := 'ping'; t := 'pong';
  for i := 1 to 100000 do
    SwapValues(s, t);
  if s <> 'ping' then halt(1);
  if t <> 'pong' then halt(2);
end.
