{ %FAIL }
{ This test must FAIL to compile — for-loop var must not be visible after the loop }
{$mode unleashed}
program tinlinevar3;

begin
  for var i := 1 to 3 do ;
  WriteLn(i); { ERROR: i is out of scope here }
end.
