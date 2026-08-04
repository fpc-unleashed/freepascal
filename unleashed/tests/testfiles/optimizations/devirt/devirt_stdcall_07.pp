{ %OPT=-O2 }
program devirt_stdcall_07;
{$mode unleashed}

// a procvar with a non-default calling convention: the rewrite may only
// fire when the conventions match exactly; results must be correct anyway

type
  TFnStd = function(x, y: longint): longint; stdcall;

function SubStd(x, y: longint): longint; stdcall;
begin
  result := x - y;
end;

function ApplyStd(f: TFnStd; x, y: longint): longint; inline;
begin
  result := f(x, y);
end;

procedure check;
begin
  var f: TFnStd := @SubStd;
  if ApplyStd(@SubStd, 50, 8) <> 42 then halt(1);
  if ApplyStd(f, 8, 50) <> -42 then halt(2);
  if f(1, 2) <> -1 then halt(3);
end;

begin
  check;
  writeln('ok');
end.
