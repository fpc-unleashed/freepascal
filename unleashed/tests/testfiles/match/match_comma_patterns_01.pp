program match_comma_patterns_01;

{$mode unleashed}

function Bucket(n: Integer): String;
begin
  match n of
    1, 2, 3:    Result := 'small';
    4, 5, 6:    Result := 'medium';
    7, 8, 9:    Result := 'big';
    _:          Result := 'other';
  end;
end;

begin
  if Bucket(2)  <> 'small'  then halt(1);
  if Bucket(5)  <> 'medium' then halt(2);
  if Bucket(9)  <> 'big'    then halt(3);
  if Bucket(99) <> 'other'  then halt(4);
end.
