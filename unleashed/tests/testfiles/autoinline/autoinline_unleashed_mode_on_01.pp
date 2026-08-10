{ %FAIL %OPT="-O3 -Seh" }
program autoinline_unleashed_mode_on_01;

{$mode unleashed}

// same shape as the objfpc variant: in unleashed mode -O3 auto-marks
// the routine and emits the "Auto inlining:" hint, which -Seh turns
// into an error - the expected failure

function double_it(x: longint): longint;
begin
  result := x * 2;
end;

begin
  if double_it(21) <> 42 then
    halt(1);
  writeln('ok');
end.
