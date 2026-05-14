program match_condition_01;

{$mode unleashed}

function Size(n: Integer): String;
begin
  match
    n > 100: Result := 'big';
    n > 10:  Result := 'medium';
    n > 0:   Result := 'small';
    _:       Result := 'zero or neg';
  end;
end;

begin
  if Size(150) <> 'big'         then halt(1);
  if Size(50)  <> 'medium'      then halt(2);
  if Size(5)   <> 'small'       then halt(3);
  if Size(0)   <> 'zero or neg' then halt(4);
  if Size(-1)  <> 'zero or neg' then halt(5);
end.
