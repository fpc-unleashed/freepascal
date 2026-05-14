program match_tuple_pattern_01;

{$mode unleashed}

function Describe(x, y: Integer): String;
begin
  var p: (Integer, Integer);
  p._1 := x;
  p._2 := y;
  match p of
    (0, 0): Result := 'origin';
    (0, _): Result := 'y-axis';
    (_, 0): Result := 'x-axis';
    _:      Result := 'other';
  end;
end;

begin
  if Describe(0, 0)   <> 'origin' then halt(1);
  if Describe(0, 5)   <> 'y-axis' then halt(2);
  if Describe(5, 0)   <> 'x-axis' then halt(3);
  if Describe(3, 4)   <> 'other'  then halt(4);
end.
