{ %FAIL }

// for-step: zero step constant must be rejected at compile time

program tb0302;

{$mode unleashed}

var
  i : integer;
begin
  for i:=1 to 10 step 0 do
    writeln(i);
end.
