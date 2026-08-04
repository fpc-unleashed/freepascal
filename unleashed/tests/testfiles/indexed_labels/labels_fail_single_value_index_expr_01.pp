{ %FAIL }
program labels_fail_single_value_index_expr_01;

{$mode unleashed}

{ a constant expression folding to a single value is rejected like a bare
  literal }

label foo[255+1];

begin
  foo[256]: writeln('unreachable');
end.
