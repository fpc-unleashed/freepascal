{ test multi-var assignment: expression evaluated exactly once }
{$mode objfpc}
{$modeswitch multivarinit}

var
  callcount: integer;

function next: integer;
begin
  inc(callcount);
  result := callcount * 10;
end;

procedure test;
var
  a, b, c: integer;
begin
  callcount := 0;
  a, b, c := next;
  { next must be called exactly once }
  if callcount <> 1 then
    halt(1);
  { all three get the same value: 10 }
  if (a <> 10) or (b <> 10) or (c <> 10) then
    halt(2);
end;

begin
  test;
end.
