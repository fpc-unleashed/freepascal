{ %FAIL }
program asyncawait_async_block_local_capture_fails_05;
{$mode unleashed}
uses SysUtils;
procedure doit;
var y: Integer;
begin
  y := 9;
  async writeln('y is ', y);
end;
begin
  doit;
end.
