program for_counter_enum_01;

{$mode unleashed}

type
  TStep = (sStart, sMiddle, sEnd);

var
  s: TStep;

begin
  for s := sStart to sEnd do
    ;
  // unleashed mode: counter holds last value
  if s <> sEnd then halt(1);
end.
