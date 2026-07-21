program out_var_class_method_01;
{$mode unleashed}

type
  TBox = class
    function TryGet(key: integer; out val: string): boolean;
  end;

function TBox.TryGet(key: integer; out val: string): boolean;
begin
  result := key = 1;
  if result then
    val := 'one'
  else
    val := '';
end;

var
  b: TBox;
begin
  b := TBox.Create;
  // out-var captured from a method call
  if not b.TryGet(1, var found) then Halt(1);
  if found <> 'one' then Halt(2);
  // discard on a method call
  if b.TryGet(2, _) then Halt(3);
  b.Free;
end.
