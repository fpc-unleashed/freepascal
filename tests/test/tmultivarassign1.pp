{ test multi-var assignment: basic assignment to existing variables }
{$mode objfpc}
{$modeswitch multivarinit}

procedure test;
var
  a, b, c: integer;
begin
  a := 0;
  b := 0;
  c := 0;
  { assign same value to multiple vars }
  a, b, c := 42;
  if (a <> 42) or (b <> 42) or (c <> 42) then
    halt(1);
  { change one, others must stay }
  a := 0;
  if (b <> 42) or (c <> 42) then
    halt(2);
end;

begin
  test;
end.
