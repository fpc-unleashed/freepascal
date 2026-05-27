{ %FAIL }
{ shortcut is gated on unleashed mode - delphi mode must reject it
  with "Error in type definition" }
program array_size_shortcut_fail_outside_unleashed_01;

{$mode delphi}

var
  a: array[10] of Integer;
begin
  a[0] := 1;
end.
