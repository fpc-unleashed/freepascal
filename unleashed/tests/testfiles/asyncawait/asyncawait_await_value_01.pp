{ await a function result through a `future of T` }
program asyncawait_await_value_01;
{$mode unleashed}
uses SysUtils;
function fetch: string;
begin
  result := 'fpc unleashed';
end;
begin
  var z := async fetch;
  if await z <> 'fpc unleashed' then halt(1);
end.
