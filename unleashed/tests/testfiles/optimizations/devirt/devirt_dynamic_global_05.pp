{ %OPT=-O2 }
program devirt_dynamic_global_05;
{$mode unleashed}

// a procvar loaded from a global stays a genuinely dynamic call; it must
// dispatch to whichever routine the global holds at run time

type
  TFn = function(x: longint): longint;

var
  dyn: TFn;

function Double(x: longint): longint; inline;
begin
  result := x * 2;
end;

function Square(x: longint): longint; inline;
begin
  result := x * x;
end;

function Apply(f: TFn; x: longint): longint; inline;
begin
  result := f(x);
end;

begin
  dyn := @Double;
  if Apply(dyn, 8) <> 16 then halt(1);
  if dyn(3) <> 6 then halt(2);
  dyn := @Square;
  if Apply(dyn, 8) <> 64 then halt(3);
  if dyn(3) <> 9 then halt(4);
  writeln('ok');
end.
