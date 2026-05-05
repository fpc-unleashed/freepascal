{ %FAIL }

// for-step: step is not allowed in for-in loops

program tb0305;

{$mode unleashed}

var
  i : integer;
  arr : array[1..3] of integer = (1, 2, 3);
begin
  for i in arr step 1 do
    writeln(i);
end.
