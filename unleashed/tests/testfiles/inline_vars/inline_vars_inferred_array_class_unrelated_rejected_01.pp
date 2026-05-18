{ %FAIL }
program inline_vars_inferred_array_class_unrelated_rejected_01;
{$mode unleashed}

// first element TFoo -> array of TFoo; an unrelated class TBar is not
// assignment-compatible -> compile error. Declare a common base
// explicitly if heterogeneous class arrays are intended.

type
  TFoo = class end;
  TBar = class end;

begin
  var a := [TFoo.Create, TBar.Create];
end.
