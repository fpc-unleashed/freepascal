program match_many_branches_01;

{$mode unleashed}

function Word_(n: Integer): String;
begin
  match n of
    1: Result := 'one';
    2: Result := 'two';
    3: Result := 'three';
    4: Result := 'four';
    5: Result := 'five';
    6: Result := 'six';
    7: Result := 'seven';
    8: Result := 'eight';
    9: Result := 'nine';
    10: Result := 'ten';
    _:  Result := '?';
  end;
end;

begin
  if Word_(1)  <> 'one'   then halt(1);
  if Word_(7)  <> 'seven' then halt(2);
  if Word_(10) <> 'ten'   then halt(3);
  if Word_(99) <> '?'     then halt(4);
end.
