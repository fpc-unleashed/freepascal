program match_subject_int_01;

{$mode unleashed}

function Classify(n: Integer): String;
begin
  match n of
    1: Result := 'one';
    2: Result := 'two';
    3: Result := 'three';
    _: Result := 'other';
  end;
end;

begin
  if Classify(1)  <> 'one'   then halt(1);
  if Classify(2)  <> 'two'   then halt(2);
  if Classify(3)  <> 'three' then halt(3);
  if Classify(99) <> 'other' then halt(4);
end.
