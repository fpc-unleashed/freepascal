program caller_pure;

{ Cross-unit consumer of purelib.CALC. REDUND makes three structurally-identical
  calls to CALC across statements; when purelib's ppu carries the -OoPURE const
  verdict, -OoGVNPRE commons the 2nd and 3rd into the first (one call emitted),
  which is observationally identical to calling CALC every time. The runtime
  self-check below must pass regardless of whether the CSE fired, so the same
  program is correct with the summary present, absent, or with every switch off
  (the check script asserts bit-exact behaviour). }

{$mode objfpc}

uses
  purelib;

var
  g_fail: longint;

function redund(a: longint): longint; noinline;
var
  t, r: longint;
begin
  t := calc(a);
  r := t + calc(a) + calc(a); { 2nd and 3rd calc(a) are fully redundant }
  redund := r;
end;

var
  i, want: longint;
begin
  g_fail := 0;
  for i := -4 to 4 do
    begin
      want := 3 * (i * i + 3 * i + 7);
      if redund(i) <> want then
        begin
          writeln('FAIL i=', i, ' got=', redund(i), ' want=', want);
          inc(g_fail);
        end;
    end;
  if g_fail = 0 then
    writeln('ALL OK')
  else
    Halt(1);
end.
