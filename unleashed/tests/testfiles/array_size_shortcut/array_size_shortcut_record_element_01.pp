program array_size_shortcut_record_element_01;

{$mode unleashed}

type
  TPoint = record
    x, y: Integer;
    name: String;
  end;

var
  pts: array[3] of TPoint;
  m: array[2, 2] of TPoint;
  i, j: Integer;
begin
  for i := 0 to 2 do
    begin
      pts[i].x := i;
      pts[i].y := i * i;
      pts[i].name := 'p' + Chr(Ord('0') + i);
    end;
  if pts[0].x <> 0 then halt(1);
  if pts[2].y <> 4 then halt(2);
  if pts[1].name <> 'p1' then halt(3);

  // multi-dim of records
  for i := 0 to 1 do
    for j := 0 to 1 do
      begin
        m[i, j].x := i * 10 + j;
        m[i, j].name := 'm';
      end;
  if m[1, 1].x <> 11 then halt(4);
  if m[0, 1].name <> 'm' then halt(5);
end.
