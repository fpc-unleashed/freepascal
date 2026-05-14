program compound_c_style_01;

{$mode unleashed}

begin
  // C-style operators are available in unleashed mode without {$coperators on}
  var x := 10;
  x += 5;
  if x <> 15 then halt(1);
  x -= 3;
  if x <> 12 then halt(2);
  x *= 4;
  if x <> 48 then halt(3);

  // /= forces real semantics; integer LHS would be a type mismatch
  var f := 10.0;
  f /= 4.0;
  if (f < 2.49) or (f > 2.51) then halt(4);
end.
