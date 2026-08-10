{ %OPT="-O3 -Seh" }
program autoinline_objfpc_mode_off_01;

{$mode objfpc}

// auto inlining applies to unleashed units only: in objfpc mode -O3
// must not auto-mark this routine. -Seh promotes hints to errors, so
// the "Auto inlining:" hint breaks the build if the marking comes back.

function double_it(x: longint): longint;
begin
  result := x * 2;
end;

begin
  if double_it(21) <> 42 then
    halt(1);
  writeln('ok');
end.
