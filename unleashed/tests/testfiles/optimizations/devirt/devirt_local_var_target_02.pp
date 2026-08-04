{ %OPT=-O2 }
program devirt_local_var_target_02;
{$mode unleashed}

// @routine stored in a local procvar, then passed to an inline wrapper
// and called directly through the local

type
  TFn = function(x: longint): longint;

function Triple(x: longint): longint; inline;
begin
  result := x * 3;
end;

function Apply(f: TFn; x: longint): longint; inline;
begin
  result := f(x);
end;

procedure check;
begin
  var f := @Triple;
  if Apply(f, 7) <> 21 then halt(1);
  if f(10) <> 30 then halt(2);
end;

begin
  check;
  writeln('ok');
end.
