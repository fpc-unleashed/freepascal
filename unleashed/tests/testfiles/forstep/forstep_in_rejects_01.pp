{ %FAIL }
program forstep_in_rejects_01;

{$mode unleashed}

begin
  // for-in does not accept step
  var arr: array of Integer := [1, 2, 3];
  for var x in arr step 2 do
    WriteLn(x);
end.
