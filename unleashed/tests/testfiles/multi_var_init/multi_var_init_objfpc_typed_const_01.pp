{ test multi-var init: typed constants }
{$mode objfpc}
{$modeswitch multivarinit}

type
  TRec = record x, y: integer; end;

const
  a, b, c: integer = 99;
  r1, r2: TRec = (x: 1; y: 2);

begin
  if (a <> 99) or (b <> 99) or (c <> 99) then
    halt(1);
  if (r1.x <> 1) or (r1.y <> 2) then
    halt(2);
  if (r2.x <> 1) or (r2.y <> 2) then
    halt(3);
end.
