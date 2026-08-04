program zeroinit_block_scoped_for_var_13;

{$mode unleashed}

procedure DirtyStack;
var
  a: array[0..15] of Integer;
  i: Integer;
begin
  for i := 0 to 15 do
    a[i] := 2222 + i;
  if a[0] = 0 then halt(10);
end;

procedure CheckZero; zeroinit;
begin
  { zeroing happens once at routine entry, so only the first
    iteration sees the pristine value }
  for var i := 0 to 3 do
    begin
      var x: Integer;
      if (i = 0) and (x <> 0) then halt(1);
      x := i + 1;
      if x = 0 then halt(2);
    end;
end;

begin
  DirtyStack;
  CheckZero;
end.
