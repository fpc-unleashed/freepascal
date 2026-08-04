{ %OPT=-O2 }
program devirt_literal_addr_inline_01;
{$mode unleashed}

// a literal @routine argument to an inline wrapper resolves to a direct
// call and the target inlines; verify the computed values stay correct

type
  TFn = function(x: longint): longint;

var
  side: longint;

function Double(x: longint): longint; inline;
begin
  result := x * 2;
end;

function AddSeven(x: longint): longint; inline;
begin
  result := x + 7;
end;

function Tally(x: longint): longint;
begin
  inc(side);
  result := x - 1;
end;

function Apply(f: TFn; x: longint): longint; inline;
begin
  result := f(x);
end;

begin
  if Apply(@Double, 21) <> 42 then halt(1);
  if Apply(@AddSeven, 10) <> 17 then halt(2);
  // non-inline target still callable through the wrapper
  if Apply(@Tally, 5) <> 4 then halt(3);
  if side <> 1 then halt(4);
  // nested use inside an expression
  if Apply(@Double, Apply(@AddSeven, 3)) <> 20 then halt(5);
  writeln('ok');
end.
