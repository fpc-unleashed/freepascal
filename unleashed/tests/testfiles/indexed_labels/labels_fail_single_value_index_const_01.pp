{ %FAIL }
program labels_fail_single_value_index_const_01;

{$mode unleashed}

{ the single-value check runs on the folded constant, so a named constant
  cannot smuggle in what a bare literal is denied }

const
  IDX = 256;

label foo[IDX];

begin
  foo[256]: writeln('unreachable');
end.
