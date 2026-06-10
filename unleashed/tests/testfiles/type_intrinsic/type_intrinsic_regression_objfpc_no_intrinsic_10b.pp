{ %FAIL }
program type_intrinsic_regression_objfpc_no_intrinsic_10b;

{$mode objfpc}

// Type() intrinsic must NOT work outside unleashed
var
  x: Integer;
  y: Type(x);
begin
  x := 1;
  y := 2;
end.
