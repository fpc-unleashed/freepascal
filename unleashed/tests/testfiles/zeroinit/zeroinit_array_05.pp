program zeroinit_array_05;

{$mode unleashed}

type
  TArr4 = array[0..3] of Integer;

procedure DirtyStack;
var
  arr: TArr4;
  i: Integer;
begin
  for i := 0 to 3 do
    arr[i] := 99;
  if arr[0]+arr[1]+arr[2]+arr[3] = 0 then halt(10);
end;

procedure CheckZero; zeroinit;
var
  arr: TArr4;
  i: Integer;
begin
  for i := 0 to 3 do
    if arr[i] <> 0 then halt(1);
end;

begin
  DirtyStack;
  CheckZero;
end.
