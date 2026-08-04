{ %OPT=-O2 }
program procvar_devirt_explicit_inline_01;
{$mode unleashed}

// without autoinlining the devirtualization still triggers when the
// wrapper is marked inline explicitly

type
  TFn = function(x: longint): longint;

function Doubler(x: longint): longint; inline;
begin
  result := x * 2;
end;

function Tripler(x: longint): longint;
begin
  result := x * 3;
end;

function Apply(f: TFn; x: longint): longint; inline;
begin
  result := f(x);
end;

begin
  if Apply(@Doubler, 6) <> 12 then Halt(10);
  // target without inline: devirtualized to a direct call, not expanded
  if Apply(@Tripler, 6) <> 18 then Halt(11);
  if TFn(@Doubler)(21) <> 42 then Halt(12);
end.
