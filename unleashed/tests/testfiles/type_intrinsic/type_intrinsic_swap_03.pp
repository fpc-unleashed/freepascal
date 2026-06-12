program type_intrinsic_swap_03;

{$mode unleashed}

var
  A: array of Integer;
  tmp: Type(A[0]);
  i, j: Integer;
begin
  SetLength(A, 5);
  A[0] := 10; A[1] := 20; A[2] := 30; A[3] := 40; A[4] := 50;
  i := 1; j := 3;
  tmp := A[i];
  A[i] := A[j];
  A[j] := tmp;
  if (A[1] <> 40) or (A[3] <> 20) then Halt(1);
  if (A[0] <> 10) or (A[2] <> 30) or (A[4] <> 50) then Halt(2);
end.
