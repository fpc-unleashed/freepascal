{ %FAIL }

// `not in S` is only available in mode unleashed
// in other modes the parser stops at `not` and emits a syntax error

program not_in_fail_outside_unleashed_01;

{$mode objfpc}

type
  tfruit = (apple, orange);
  tfruits = set of tfruit;

var
  s : tfruits;
begin
  s := [apple];
  if apple not in s then
    s := [];
end.
