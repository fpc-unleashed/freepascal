{ %OPT=-O4 %CHECKBIN_LACKS="ZZSWTELSEMARK" }
{ Proof that -OoSWITCHTABLE actually fired, attributable to this pass.  The case
  below fully covers its enum type, so its else part is provably unreachable and
  the transform deletes it together with the dispatch.  The else emits a unique
  string marker ZZSWTELSEMARK; once the case is converted to a static lookup
  table the whole else (and its marker) is gone from the binary -- asserted via
  %CHECKBIN_LACKS.  optswitchtable_disabled_01 compiles the SAME source with
  -OoNOSWITCHTABLE and asserts the marker is STILL PRESENT, so the deletion is
  SWITCHTABLE's doing and nothing else's.  Halt(nonzero) = failure. }
program optswitchtable_checkbin_01;
{$mode objfpc}{$H+}

type
  TC = (a, b, c, d, e);

function w(x: TC): longint; noinline;
var
  r: longint;
begin
  r := 0;
  case x of
    a: r := 10;
    b: r := 20;
    c: r := 30;
    d: r := 40;
    e: r := 50;
  else
    writeln('ZZSWTELSEMARK');
  end;
  w := r;
end;

var
  x: TC;
begin
  for x := a to e do
    if w(x) <> (ord(x) + 1) * 10 then
      Halt(1);
  Halt(0);
end.
