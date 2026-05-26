program array_literal_paren_first_elem_01;

{$mode unleashed}

{ regression: [(1)/100] used to fail with "]" expected but "/" found
  because the tuple-aware path in factor_read_set consumed `(expr)`
  itself instead of letting factor handle it and continue the binary
  expression naturally }
begin
  var a := [(1)/100, 0.5, (2+3)*10];
  if Length(a) <> 3 then halt(1);
  if a[0] < 0.0099 then halt(2);
  if a[0] > 0.0101 then halt(3);
  if a[1] <> 0.5 then halt(4);
  if a[2] <> 50 then halt(5);
end.
