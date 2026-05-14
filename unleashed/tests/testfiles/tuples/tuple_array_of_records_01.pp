program tuple_array_of_records_01;

{$mode unleashed}

type
  TItem = record
    name: String;
    pos:  (x, y: Integer);
  end;

begin
  var items: array of TItem;
  SetLength(items, 2);
  items[0].name := 'a'; items[0].pos.x := 10; items[0].pos.y := 20;
  items[1].name := 'b'; items[1].pos.x := 30; items[1].pos.y := 40;

  if items[0].pos.x <> 10 then halt(1);
  if items[1].pos.y <> 40 then halt(2);
  if items[1].name  <> 'b' then halt(3);
end.
