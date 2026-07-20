{ the one-statement form async <stmt> works like a one-statement block }
program asyncawait_async_single_stmt_34;
{$mode unleashed}
uses SysUtils;
var
  counter: Integer;
begin
  counter := 0;
  { while statement }
  var f := async while counter < 5 do counter := counter + 1;
  await f;
  if counter <> 5 then halt(1);
  { structured statement }
  var g := async if counter = 5 then counter := 10;
  await g;
  if counter <> 10 then halt(2);
  { for statement, local captured by reference }
  var t := 0;
  var h := async for var i := 1 to 4 do t := t + i;
  await h;
  if t <> 10 then halt(3);
  { repeat statement }
  var r := async repeat t := t - 1 until t = 0;
  await r;
  if t <> 0 then halt(4);
  { Cancelled is readable in the one-statement body }
  var c := async while not Cancelled do Sleep(1);
  c.Cancel;
  await c;
  if not c.Cancelled then halt(5);
end.
