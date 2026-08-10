{ %OPT="-O2 -Seh" }
program devirt_inline_off_10;
{$mode unleashed}

// `$inline off` at the call site keeps the call indirect: no rewrite,
// so the store into the procvar survives and a debugger still sees it.
// -Seh promotes hints to errors, so the "Devirtualized call:" hint
// breaks the build if the region stops being honored.

function triple(x: longint): longint;
begin
  result := x * 3;
end;

{$inline off}

procedure stepped_through;
begin
  var f := @triple;
  if f(4) <> 12 then
    halt(1);
end;

{$inline on}

begin
  stepped_through;
  writeln('ok');
end.
