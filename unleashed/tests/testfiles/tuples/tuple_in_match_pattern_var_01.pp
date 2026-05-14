program tuple_in_match_pattern_var_01;

{$mode unleashed}

function Quadrant(x, y: Integer): String;
begin
  var p: (Integer, Integer);
  p._1 := x; p._2 := y;
  match p of
    (0, 0):    Result := 'origin';
    (_, 0):    Result := 'x-axis';
    (0, _):    Result := 'y-axis';
    _:         Result := 'somewhere';
  end;
end;

begin
  if Quadrant(0, 0)  <> 'origin'    then halt(1);
  if Quadrant(5, 0)  <> 'x-axis'    then halt(2);
  if Quadrant(0, 7)  <> 'y-axis'    then halt(3);
  if Quadrant(3, 4)  <> 'somewhere' then halt(4);
end.
