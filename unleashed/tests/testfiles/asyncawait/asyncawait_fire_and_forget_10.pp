{ a discarded future still runs (the worker holds the only reference) }
program asyncawait_fire_and_forget_10;
{$mode unleashed}
uses SysUtils;
var ran: Integer;
begin
  ran := 0;
  async begin
    ran := 99;
  end;
  Sleep(400);
  if ran <> 99 then halt(1);
end.
