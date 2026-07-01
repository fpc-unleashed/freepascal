program zeroinit_basic_integer_01;

{$mode unleashed}

procedure DirtyStack;
var
  i, j, k: Integer;
begin
  i := 1111;
  j := 2222;
  k := 3333;
  if i+j+k = 0 then halt(10);
end;

procedure CheckZero; zeroinit;
var
  i, j, k: Integer;
begin
  if i <> 0 then halt(1);
  if j <> 0 then halt(2);
  if k <> 0 then halt(3);
end;

begin
  DirtyStack;
  CheckZero;
end.
