{ %FAIL }
{ empty fixed array is almost always a bug; parser rejects array[0]
  the same way it rejects array[5..0] }
program array_size_shortcut_fail_zero_01;

{$mode unleashed}

var
  a: array[0] of Integer;
begin
end.
