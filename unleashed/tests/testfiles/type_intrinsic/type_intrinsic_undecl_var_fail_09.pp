{ %FAIL }
program type_intrinsic_undecl_var_fail_09;

{$mode unleashed}

var
  y: Type(undeclared);  // undeclared name must error
begin
end.
