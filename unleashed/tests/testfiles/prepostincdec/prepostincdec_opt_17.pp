{ %OPT=-O3 }
program prepostincdec_opt_17;
{$mode unleashed}
var
  a: Integer;
  p: PInteger;
  arr: array[0..3] of Integer;
begin
  a := 10;
  if PostInc(a) <> 10 then halt(1);
  if PreInc(a, 3) <> 14 then halt(2);
  if PostDec(a, 4) <> 14 then halt(3);
  if PreDec(a) <> 9 then halt(4);
  arr[0] := 1; arr[1] := 2; arr[2] := 3; arr[3] := 4;
  p := @arr[0];
  if PostInc(p, 2)^ <> 1 then halt(5);
  if p^ <> 3 then halt(6);
  a := 0;
  if PostInc(a) + PostInc(a) <> 1 then halt(7);
end.
