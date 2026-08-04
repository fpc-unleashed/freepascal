{ test multi-var init: local vars }
{$mode objfpc}
{$modeswitch multivarinit}

procedure test;
var
  a, b, c: integer = 10;
begin
  if (a <> 10) or (b <> 10) or (c <> 10) then
    halt(1);
  a := 0;
  if (b <> 10) or (c <> 10) then
    halt(2);
end;

begin
  test;
end.
