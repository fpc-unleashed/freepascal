{ %FAIL }
program inline_vars_inferred_array_int_then_string_rejected_01;
{$mode unleashed}

// first element is an integer -> array of LongInt; subsequent string
// literal cannot be cast to an ordinal -> compile error

begin
  var a := [42, 'oops'];
end.
