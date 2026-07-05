{ Cancel raises the flag the block reads as Cancelled; the loop exits }
program asyncawait_control_cancel_roundtrip_19;
{$mode unleashed}
uses SysUtils;
var spun: boolean;
begin
  spun := false;
  var h := async begin
    while not Cancelled do begin
      spun := true;
      Sleep(1);
    end;
  end;
  while not spun do Sleep(1);
  if h.Done then halt(1);
  h.Cancel;
  await h;
  if not h.Done then halt(2);
  if not h.Cancelled then halt(3);
end.
