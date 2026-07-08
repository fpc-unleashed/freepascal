{ %OPT="-O4" }
{ Negative control: branchy routines that contain NO cold error/raise region,
  so -OoBLOCKORDER must find nothing to sink and leave them semantically
  unchanged.  Plenty of conditional jumps (classify trees, loops, nested ifs)
  none of which guards a raise/assert/RunError, exercising that the pass does
  not misfire on ordinary control flow. }
program optblockorder_negatives_01;
{$mode objfpc}

function classify(x: longint): longint; noinline;
begin
  if x < 0 then
    Result := -1
  else if x = 0 then
    Result := 0
  else if x < 10 then
    Result := 1
  else if x < 100 then
    Result := 2
  else
    Result := 3;
end;

function maxOf(const a: array of longint): longint; noinline;
var
  i: longint;
begin
  Result := a[0];
  for i := 1 to High(a) do
    if a[i] > Result then
      Result := a[i];
end;

function countEven(const a: array of longint): longint; noinline;
var
  i, n: longint;
begin
  n := 0;
  for i := 0 to High(a) do
    if (a[i] and 1) = 0 then
      Inc(n);
  Result := n;
end;

function gcd(a, b: longint): longint; noinline;
begin
  while b <> 0 do
    begin
      Result := a mod b;
      a := b;
      b := Result;
    end;
  Result := a;
end;

begin
  if classify(-5) <> -1 then Halt(1);
  if classify(0) <> 0 then Halt(2);
  if classify(7) <> 1 then Halt(3);
  if classify(50) <> 2 then Halt(4);
  if classify(500) <> 3 then Halt(5);

  if maxOf([3, 9, 2, 9, 1]) <> 9 then Halt(6);
  if maxOf([-4, -1, -8]) <> -1 then Halt(7);

  if countEven([1, 2, 3, 4, 5, 6]) <> 3 then Halt(8);

  if gcd(48, 36) <> 12 then Halt(9);
  if gcd(17, 5) <> 1 then Halt(10);
end.
