{ %OPT=-O3 }
program autoinline_o3_correctness_01;
{$mode unleashed}

// -O3 marks small routines for automatic inlining; results must be
// identical to the non-inlined versions (including recursion, which is
// inlined at most one level, and address-taken calls through pointers)

var sideeffects: Integer = 0;

function Tiny(x: Integer): Integer;
begin
  result := x * 3 + 1;
end;

function Bump(x: Integer): Integer;
begin
  Inc(sideeffects);
  result := x + sideeffects;
end;

function Fib(n: Integer): Integer;
begin
  if n < 2 then result := n else result := Fib(n - 1) + Fib(n - 2);
end;

type TFn = function(x: Integer): Integer;

begin
  if Tiny(5) <> 16 then Halt(10);
  var acc := 0;
  for var i := 1 to 100 do acc += Tiny(i);
  if acc <> 3 * 5050 + 100 then Halt(11);

  sideeffects := 0;
  if Bump(10) <> 11 then Halt(20);
  if Bump(10) <> 12 then Halt(21);
  if sideeffects <> 2 then Halt(22);

  if Fib(15) <> 610 then Halt(30);

  var fn: TFn := @Tiny;
  if fn(7) <> 22 then Halt(40);
end.
