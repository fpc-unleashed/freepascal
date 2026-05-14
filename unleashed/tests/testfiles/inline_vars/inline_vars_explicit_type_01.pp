program inline_vars_explicit_type_01;

{$mode unleashed}

begin
  var x: Integer := 42;
  if x <> 42 then halt(1);
  var s: String := 'hi';
  if s <> 'hi' then halt(2);
  var arr: array of Integer := [10, 20, 30];
  if Length(arr) <> 3 then halt(3);
  if arr[2] <> 30 then halt(4);
end.
