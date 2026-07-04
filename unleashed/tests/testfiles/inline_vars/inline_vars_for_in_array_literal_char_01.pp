program inline_vars_for_in_array_literal_char_01;
{$mode unleashed}

// char literals in a for-in array literal keep the loop var as Char,
// they must not be widened to AnsiString. literals are given in ordinal
// order because the loop iterates them as a set

begin
  var acc := '';
  for var c in ['a', 'b', 'c'] do
    begin
      if SizeOf(c) <> 1 then halt(1);
      acc := acc + c;
    end;
  if acc <> 'abc' then halt(2);
end.
