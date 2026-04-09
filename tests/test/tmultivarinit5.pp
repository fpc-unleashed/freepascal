{ test multi-var init: inline var with type inference }
{$mode objfpc}
{$modeswitch multivarinit}
{$modeswitch inlinevars}

procedure test;
begin
  var a, b := 42;
  if (a <> 42) or (b <> 42) then
    halt(1);
  var s1, s2 := 'hello';
  if (s1 <> 'hello') or (s2 <> 'hello') then
    halt(2);
  { verify type promotion: result should be LongInt, not byte }
  var x, y := 10;
  if SizeOf(x) <> SizeOf(LongInt) then
    halt(3);
end;

begin
  test;
end.
