program inline_vars_for_in_array_literal_no_truncation_01;
{$mode unleashed}

// regression: the for-in loop var inferred its type from the literal's
// carrier def sized to the first element, truncating longer elements.
// inference must widen string literals to AnsiString.

begin
  var i := 0;
  for var s in ['abcdefgh', 'longer than the first', 'x'] do
    begin
      if SizeOf(s) <> SizeOf(AnsiString) then halt(1);
      case i of
        0: if s <> 'abcdefgh' then halt(2);
        1: if s <> 'longer than the first' then halt(3);
        2: if s <> 'x' then halt(4);
      end;
      inc(i);
    end;
  if i <> 3 then halt(5);
end.
