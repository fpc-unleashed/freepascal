program inline_vars_in_with_record_01;

{$mode unleashed}

type
  TPoint = record
    x, y: Integer;
  end;

var
  p: TPoint;

begin
  p.x := 1; p.y := 2;
  with p do
  begin
    var diag := x + y;
    if diag <> 3 then halt(1);
    var label_ := if x = y then 'eq' else 'neq';
    if label_ <> 'neq' then halt(2);
  end;
end.
