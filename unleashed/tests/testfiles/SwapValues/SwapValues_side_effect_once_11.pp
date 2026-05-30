program SwapValues_side_effect_once_11;
{$mode unleashed}
// a side-effecting operand address is taken once: each index evaluates once
var
  arr: array[0..3] of Integer;
  calls: Integer;

function Idx: Integer;
begin
  Result := calls;
  Inc(calls);
end;

begin
  arr[0] := 100; arr[1] := 200; arr[2] := 300; arr[3] := 400;
  calls := 0;
  SwapValues(arr[Idx], arr[Idx]);
  if calls <> 2 then halt(1);
  if arr[0] <> 200 then halt(2);
  if arr[1] <> 100 then halt(3);
end.
