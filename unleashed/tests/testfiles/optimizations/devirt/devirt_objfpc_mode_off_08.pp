{ %OPT="-O2 -Seh" }
program devirt_objfpc_mode_off_08;
{$mode objfpc}

// devirtualization rewrites call sites in unleashed units only: in
// objfpc mode the local procvar call stays indirect and no hint fires.
// -Seh promotes hints to errors, so the "Devirtualized call:" hint
// breaks the build if the rewrite comes back.

type
  TFn = function(x: longint): longint;

function Triple(x: longint): longint;
begin
  result := x * 3;
end;

procedure check;
var
  f: TFn;
begin
  f := @Triple;
  if f(4) <> 12 then
    halt(1);
end;

begin
  check;
  writeln('ok');
end.
