{ %FAIL }

// for-step: negative step constant must be rejected at compile time

program tb0303;

{$mode unleashed}

var
  i : integer;
begin
  for i:=1 to 10 step -2 do
    writeln(i);
end.
