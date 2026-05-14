program match_range_pattern_01;

{$mode unleashed}

function Bucket(n: Integer): String;
begin
  match n of
    0..9:    Result := 'single';
    10..99:  Result := 'double';
    100..999: Result := 'triple';
    _:       Result := 'big';
  end;
end;

begin
  if Bucket(5)    <> 'single' then halt(1);
  if Bucket(42)   <> 'double' then halt(2);
  if Bucket(500)  <> 'triple' then halt(3);
  if Bucket(9999) <> 'big'    then halt(4);
end.
