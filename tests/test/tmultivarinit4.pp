{ test multi-var init: inline var with explicit type }
{$mode objfpc}
{$modeswitch multivarinit}
{$modeswitch inlinevars}

procedure test;
begin
  var a, b: integer := 55;
  if (a <> 55) or (b <> 55) then
    halt(1);
  a := 0;
  if b <> 55 then
    halt(2);
end;

begin
  test;
end.
