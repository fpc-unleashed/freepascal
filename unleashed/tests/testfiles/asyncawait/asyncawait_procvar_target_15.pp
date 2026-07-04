{ a procedural-variable call as the async target; the procvar is snapshotted }
program asyncawait_procvar_target_15;
{$mode unleashed}
uses SysUtils;
function forty: Integer;
begin
  result := 40;
end;
function two: Integer;
begin
  result := 2;
end;
type TIntFn = function: Integer;
var pv: TIntFn;
begin
  pv := @forty;
  var f := async pv();
  pv := @two;   // does not affect f (snapshot)
  if await f <> 40 then halt(1);
  var g := async pv();
  if await g <> 2 then halt(2);
end.
