{ %NORUN }
unit asyncawait_unitinit_helper;
{$mode unleashed}
interface
var ready: Integer;
implementation
var w: future;
procedure setready;
begin
  ready := 7;
end;
initialization
  w := async setready;
  await w;
end.
