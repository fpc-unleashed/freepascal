{ test multi-var init: function call evaluated once }
{$mode objfpc}
{$modeswitch multivarinit}
{$modeswitch inlinevars}

var
  callcount: integer = 0;

function GetValue: integer;
begin
  inc(callcount);
  result := 77;
end;

procedure test;
begin
  var a, b: integer := GetValue;
  if (a <> 77) or (b <> 77) then
    halt(1);
  if callcount <> 1 then
    halt(2);
end;

begin
  test;
end.
