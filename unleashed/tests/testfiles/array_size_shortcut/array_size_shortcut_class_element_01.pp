program array_size_shortcut_class_element_01;

{$mode unleashed}

// class references are pointers; the array holds N slots of those
type
  TBox = class
    Value: Integer;
    constructor Create(v: Integer);
  end;

constructor TBox.Create(v: Integer);
begin
  Value := v;
end;

var
  boxes: array[4] of TBox;
  i, total: Integer;
begin
  for i := 0 to 3 do
    boxes[i] := TBox.Create(i * 10);
  total := 0;
  for i := 0 to 3 do
    total := total + boxes[i].Value;
  if total <> 60 then halt(1);
  if boxes[2].Value <> 20 then halt(2);
  for i := 0 to 3 do
    boxes[i].Free;
end.
