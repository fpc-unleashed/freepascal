{ %OPT="-O4 -OoNOSWITCHTABLE" %CHECKBIN_HAS="ZZSWTELSEMARK" }
{ Control for optswitchtable_checkbin_01: identical source, but with the
  switch-table pass explicitly disabled via -OoNOSWITCHTABLE (every other -O4
  optimization still on).  The full-coverage case is lowered classically, its
  else block is NOT deleted, so the unique marker ZZSWTELSEMARK is still present
  in the binary -- asserted via %CHECKBIN_HAS.  This proves the else/dispatch
  removal seen in optswitchtable_checkbin_01 is attributable to SWITCHTABLE
  specifically.  Same source, same observable runtime behaviour. }
program optswitchtable_disabled_01;
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
