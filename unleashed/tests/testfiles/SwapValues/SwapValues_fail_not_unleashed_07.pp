{ %FAIL }
program SwapValues_fail_not_unleashed_07;
{$mode objfpc}
// SwapValues is gated on {$mode unleashed}; outside it the identifier is unknown
var
  a, b: Integer;
begin
  a := 1; b := 2;
  SwapValues(a, b);
end.
