program match_condition_complex_01;

{$mode unleashed}

function Classify(n: Integer): String;
begin
  match
    (n > 0) and (n mod 2 = 0): Result := 'positive even';
    (n > 0) and (n mod 2 = 1): Result := 'positive odd';
    n = 0:                     Result := 'zero';
    _:                         Result := 'negative';
  end;
end;

begin
  if Classify(4)  <> 'positive even' then halt(1);
  if Classify(7)  <> 'positive odd'  then halt(2);
  if Classify(0)  <> 'zero'          then halt(3);
  if Classify(-3) <> 'negative'      then halt(4);
end.
