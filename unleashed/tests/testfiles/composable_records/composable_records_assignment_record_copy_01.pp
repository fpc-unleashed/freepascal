program composable_records_assignment_record_copy_01;

{$mode unleashed}

type
  TBase = record
    x, y: Integer;
  end;
  TDerived = record
    embed TBase;
    z: Integer;
  end;

var
  a, b: TDerived;
begin
  a.x := 1; a.y := 2; a.z := 3;
  b := a;
  if b.x <> 1 then halt(1);
  if b.y <> 2 then halt(2);
  if b.z <> 3 then halt(3);
  { mutate b, a stays }
  b.x := 99;
  if a.x <> 1 then halt(4);
  if b.x <> 99 then halt(5);
end.
