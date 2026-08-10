{ %FAIL %OPT="-O2 -Seh" }
program devirt_unleashed_mode_on_09;
{$mode unleashed}

// same shape as the objfpc variant: the local procvar call
// devirtualizes and emits the "Devirtualized call:" hint, which -Seh
// turns into an error - the expected failure

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
