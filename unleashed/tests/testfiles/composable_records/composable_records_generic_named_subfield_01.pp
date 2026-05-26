program composable_records_generic_named_subfield_01;

{$mode unleashed}

type
  TBox<T> = record
    item: T;
    weight: Single;
  end;

  TVec = record
    x, y: LongInt;
  end;

var
  b: TBox<TVec>;
begin
  b.item.x := 1;
  b.item.y := 2;
  b.weight := 0.5;
  if b.item.x <> 1 then halt(1);
  if b.item.y <> 2 then halt(2);
  if b.weight <> 0.5 then halt(3);
end.
