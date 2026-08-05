{ %OPT=-O3 }
program optswitch_autoinline_suffix_01;
{$mode unleashed}

// trailing + and - on an optimization switch name set and clear it;
// the NO prefix form stays supported; results are identical either way

{$optimization autoinline-}

function tripler(x: longint): longint;
begin
  result := x * 3;
end;

{$optimization noautoinline}

function quadrupler(x: longint): longint;
begin
  result := x * 4;
end;

{$optimization autoinline+}

function doubler(x: longint): longint;
begin
  result := x * 2;
end;

begin
  if tripler(5) <> 15 then Halt(10);
  if quadrupler(5) <> 20 then Halt(11);
  if doubler(5) <> 10 then Halt(12);
end.
