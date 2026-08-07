program prepostincdec_eval_once_05;
{$mode unleashed}
var
  arr: array[0..2] of Integer;
  calls: Integer;

function idx: Integer;
begin
  inc(calls);
  result := 1;
end;

begin
  calls := 0;
  arr[1] := 7;
  if PostInc(arr[idx], 10) <> 7 then halt(1);
  if arr[1] <> 17 then halt(2);
  if calls <> 1 then halt(3);
  if PreDec(arr[idx], 2) <> 15 then halt(4);
  if calls <> 2 then halt(5);
end.
