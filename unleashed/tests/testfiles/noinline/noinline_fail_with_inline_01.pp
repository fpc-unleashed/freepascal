{ %FAIL }
program noinline_fail_with_inline_01;
{$mode unleashed}

// inline and noinline are mutually exclusive on one routine

function doubler(x: longint): longint; inline; noinline;
begin
  result := x * 2;
end;

begin
  writeln(doubler(3));
end.
