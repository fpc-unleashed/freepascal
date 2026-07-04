{ `async begin..end` captures referenced locals by reference }
program asyncawait_capture_by_ref_04;
{$mode unleashed}
uses SysUtils;
var counter: Integer;
begin
  counter := 0;
  var w := async begin
    counter := counter + 41;
  end;
  await w;
  if counter <> 41 then halt(1);
end.
