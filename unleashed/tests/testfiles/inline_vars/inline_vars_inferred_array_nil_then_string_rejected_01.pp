{ %FAIL }
program inline_vars_inferred_array_nil_then_string_rejected_01;
{$mode unleashed}

// first element nil -> array of Pointer; a string literal is not
// pointer-assignable -> compile error. For an actually mixed bag use
// `array of Variant` explicitly.

begin
  var a := [nil, 'oops'];
end.
