{$mode unleashed}
program tinlinevar1;

uses
  SysUtils;

procedure TestBasicInlineVar;
begin
  { Typed, no initializer }
  var X: Integer;
  X := 10;
  if X <> 10 then
    Halt(1);

  { Typed with initializer }
  var Y: Integer := 42;
  if Y <> 42 then
    Halt(2);

  { Type inference }
  var Z := 100;
  if Z <> 100 then
    Halt(3);

  { Multiple names }
  var A, B: Integer;
  A := 1;
  B := 2;
  if A + B <> 3 then
    Halt(4);

  { String type inference }
  var S := 'hello';
  if S <> 'hello' then
    Halt(5);
end;

procedure TestForLoopInlineVar;
var
  Sum: Integer;
begin
  Sum := 0;

  { for var with explicit type }
  for var I: Integer := 1 to 5 do
    Sum := Sum + I;
  if Sum <> 15 then
    Halt(10);

  { for var with type inference }
  Sum := 0;
  for var J := 1 to 5 do
    Sum := Sum + J;
  if Sum <> 15 then
    Halt(11);
end;

procedure TestForInInlineVar;
var
  Arr: array[0..2] of Integer;
  Sum: Integer;
begin
  Arr[0] := 10;
  Arr[1] := 20;
  Arr[2] := 30;

  Sum := 0;
  for var Item in Arr do
    Sum := Sum + Item;
  if Sum <> 60 then
    Halt(20);
end;

begin
  TestBasicInlineVar;
  TestForLoopInlineVar;
  TestForInInlineVar;
  WriteLn('OK');
end.
