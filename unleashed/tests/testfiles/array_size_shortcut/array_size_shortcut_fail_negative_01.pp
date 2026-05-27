{ %FAIL }
{ negative size hits the same lower-greater-than-upper check }
program array_size_shortcut_fail_negative_01;

{$mode unleashed}

var
  a: array[-5] of Integer;
begin
end.
