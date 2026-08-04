{$mode unleashed}
program inline_vars_combined_forms_01;

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

procedure TestBlockScoping;
var
  OuterVal: Integer;
begin
  OuterVal := 0;

  { Variable declared in a nested block is local to that block }
  begin
    var Inner := 99;
    OuterVal := Inner;
  end;
  if OuterVal <> 99 then
    Halt(30);

  { for-loop inline var is scoped to the loop }
  var Sum := 0;
  for var I := 1 to 3 do
    Sum := Sum + I;
  if Sum <> 6 then
    Halt(33);
  { I is not accessible here (would be a compile error) }
end;

begin
  TestBasicInlineVar;
  TestForLoopInlineVar;
  TestForInInlineVar;
  TestBlockScoping;
  WriteLn('OK');
end.
