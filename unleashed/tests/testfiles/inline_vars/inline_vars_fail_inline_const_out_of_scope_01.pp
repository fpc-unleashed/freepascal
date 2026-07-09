{ %FAIL }
program inline_vars_fail_inline_const_out_of_scope_01;
// inline const is scoped to its block - use after the block must not compile

{$mode unleashed}

var x: integer;
begin
  begin
    const K = 1;
    x := K;
  end;
  x := K;
end.
