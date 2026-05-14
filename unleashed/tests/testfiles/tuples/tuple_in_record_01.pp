program tuple_in_record_01;

{$mode unleashed}

type
  TItem = record
    id: Integer;
    pt: (x, y: Integer);
  end;

begin
  var t: TItem;
  t.id := 7;
  t.pt.x := 10;
  t.pt.y := 20;
  if t.id <> 7 then halt(1);
  if t.pt.x <> 10 then halt(2);
  if t.pt.y <> 20 then halt(3);
end.
