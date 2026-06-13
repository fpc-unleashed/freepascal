{ %FAIL }
program asyncawait_writeln_future_fails_01;
{$mode unleashed}
uses SysUtils;
function fetch: string;
begin
  result := 'x';
end;
begin
  var z := async fetch;
  writeln(z);
end.
