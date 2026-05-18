{ %FAIL }
program inline_vars_inferred_array_mixed_types_rejected_01;
{$mode unleashed}

// first element is AnsiString -> the integers 1 and 2 cannot be assigned
// to AnsiString, producing a compile error. For genuinely mixed bags use
// `var x: array of Variant := [...]` explicitly.

begin
  var a := ['hello', 1, 2, 'world'];
end.
