{ a method call snapshots self (the reference) and the arguments by value }
program asyncawait_method_snapshot_09;
{$mode unleashed}
uses SysUtils;
type
  TAdder = class
    base: Integer;
    function addTo(x: Integer): Integer;
  end;
function TAdder.addTo(x: Integer): Integer;
begin
  Sleep(50);
  result := base + x;
end;
var
  obj: TAdder;
  xx: Integer;
begin
  obj := TAdder.Create;
  obj.base := 10;
  xx := 5;
  var r := async obj.addTo(xx);
  xx := 100;
  if await r <> 15 then halt(1);
  obj.Free;
end.
