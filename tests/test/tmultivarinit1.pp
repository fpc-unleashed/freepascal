{ test multi-var init: global static vars }
{$mode objfpc}
{$modeswitch multivarinit}

var
  a, b, c: integer = 42;
  x, y: boolean = true;
  s1, s2: string = 'hello';

begin
  if (a <> 42) or (b <> 42) or (c <> 42) then
    halt(1);
  if not x or not y then
    halt(2);
  if (s1 <> 'hello') or (s2 <> 'hello') then
    halt(3);
  { values are independent copies }
  a := 0;
  if (b <> 42) or (c <> 42) then
    halt(4);
  s1 := 'changed';
  if s2 <> 'hello' then
    halt(5);
end.
