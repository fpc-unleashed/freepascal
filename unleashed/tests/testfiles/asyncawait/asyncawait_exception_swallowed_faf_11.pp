{ an exception in a fire-and-forget block is swallowed, not fatal }
program asyncawait_exception_swallowed_faf_11;
{$mode unleashed}
uses SysUtils;
var after: Integer;
begin
  after := 0;
  async begin
    raise Exception.Create('ignored');
  end;
  Sleep(400);
  after := 1;
  if after <> 1 then halt(1);
end.
