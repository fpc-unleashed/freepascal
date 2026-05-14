program match_with_side_effect_in_condition_01;

{$mode unleashed}

var
  call_count: Integer = 0;

function Bigger(a, b: Integer): Boolean;
begin
  Inc(call_count);
  Result := a > b;
end;

function Classify(n: Integer): String;
begin
  match
    Bigger(n, 100): Result := 'huge';
    Bigger(n, 10):  Result := 'medium';
    _:              Result := 'small';
  end;
end;

begin
  call_count := 0;
  if Classify(50)  <> 'medium' then halt(1);
  if call_count    <> 2        then halt(2);   // first false, second true

  call_count := 0;
  if Classify(200) <> 'huge'   then halt(3);
  if call_count    <> 1        then halt(4);   // first true, short-circuits

  call_count := 0;
  if Classify(5)   <> 'small'  then halt(5);
  if call_count    <> 2        then halt(6);   // both false, fall to _
end.
