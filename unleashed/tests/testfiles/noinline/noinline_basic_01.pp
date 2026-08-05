{ %OPT=-O3 }
program noinline_basic_01;
{$mode unleashed}

// noinline keeps the routine out of automatic inlining even at -O3;
// calls keep working, direct and through a procvar

type
  TFn = function(x: longint): longint;

function doubler(x: longint): longint; noinline;
begin
  result := x * 2;
end;

function apply(f: TFn; x: longint): longint;
begin
  result := f(x);
end;

begin
  if doubler(7) <> 14 then Halt(10);
  if apply(@doubler, 6) <> 12 then Halt(11);
end.
