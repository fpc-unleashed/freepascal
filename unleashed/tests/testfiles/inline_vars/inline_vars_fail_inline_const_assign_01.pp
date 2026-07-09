{ %FAIL }
program inline_vars_fail_inline_const_assign_01;
// inline const is not assignable

{$mode unleashed}

begin
  const K = 5;
  K := 6;
end.
