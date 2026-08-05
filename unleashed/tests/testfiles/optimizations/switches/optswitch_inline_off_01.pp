{ %OPT=-O3 }
program optswitch_inline_off_01;
{$mode unleashed}

// `$inline off` at the call site suppresses expansion of any routine,
// forced inline included; behavior of the calls must not change

type
  TFn = function(x: longint): longint;

function doubler(x: longint): longint; inline;
begin
  result := x * 2;
end;

function apply(f: TFn; x: longint): longint; inline;
begin
  result := f(x);
end;

{$inline off}

function wrapped(x: longint): longint;
begin
  result := apply(@doubler, x);
end;

{$inline on}

begin
  if wrapped(6) <> 12 then Halt(10);
  if apply(@doubler, 21) <> 42 then Halt(11);
end.
