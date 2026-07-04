{ `var z := async fn` infers `future of T` (no char/int promotion) }
program asyncawait_type_inference_08;
{$mode unleashed}
uses SysUtils, TypInfo;
function pick: Char;
begin
  result := 'q';
end;
begin
  var z := async pick;
  if await z <> 'q' then halt(1);
end.
