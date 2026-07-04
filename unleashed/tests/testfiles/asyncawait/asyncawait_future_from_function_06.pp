{ a future returned from a function and passed through a parameter }
program asyncawait_future_from_function_06;
{$mode unleashed}
uses SysUtils;
function fetch: string;
begin
  result := 'ok';
end;
function startFetch: future of string;
begin
  result := async fetch;
end;
function joinIt(f: future of string): string;
begin
  result := await f;
end;
begin
  if await startFetch <> 'ok' then halt(1);
  if joinIt(async fetch) <> 'ok' then halt(2);
end.
