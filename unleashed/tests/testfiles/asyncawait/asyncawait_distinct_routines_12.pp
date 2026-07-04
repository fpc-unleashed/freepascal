{ futures spawned from different routines get distinct impl classes }
program asyncawait_distinct_routines_12;
{$mode unleashed}
uses SysUtils;
function teststr: string;
begin
  result := 'ok';
end;
function make_future: future of string;
begin
  result := async teststr;
end;
function other: Integer;
begin
  result := 42;
end;
begin
  if await make_future <> 'ok' then halt(1);
  var x := async other;
  if await x <> 42 then halt(2);
end.
