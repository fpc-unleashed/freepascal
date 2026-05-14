program inline_vars_subrange_type_01;

{$mode unleashed}

type
  TBucket = 0..9;

begin
  var b: TBucket := 5;
  if b <> 5 then halt(1);
  b := 9;
  if b <> 9 then halt(2);
end.
