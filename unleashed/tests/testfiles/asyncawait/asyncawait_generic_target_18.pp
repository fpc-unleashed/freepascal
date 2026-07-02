{ a generic specialization call as the async target }
program asyncawait_generic_target_18;
{$mode unleashed}
uses SysUtils;
function TwoOf<T>(a: T): T;
begin
  result := a + a;
end;
begin
  var f := async TwoOf<Integer>(21);
  if await f <> 42 then halt(1);
  var g := async TwoOf<Int64>(100);
  if await g <> 200 then halt(2);
end.
