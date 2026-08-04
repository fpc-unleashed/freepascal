{ %OPT=-O2 }
program devirt_wrapper_chain_03;
{$mode unleashed}

// a chain of two inline wrappers forwarding the procedure pointer collapses
// down to the target; verify the value survives the whole chain

type
  TFn = function(x: longint): longint;

function Negate(x: longint): longint; inline;
begin
  result := -x;
end;

function Inner(f: TFn; x: longint): longint; inline;
begin
  result := f(x);
end;

function Outer(f: TFn; x: longint): longint; inline;
begin
  result := Inner(f, x) + 100;
end;

begin
  if Outer(@Negate, 42) <> 58 then halt(1);
  if Inner(@Negate, -5) <> 5 then halt(2);
  writeln('ok');
end.
