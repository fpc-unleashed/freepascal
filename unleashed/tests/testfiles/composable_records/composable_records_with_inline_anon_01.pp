program composable_records_with_inline_anon_01;

{$mode unleashed}

type
  TPoint3D = record
    record
      x, y, z: LongInt;
    end;
    w: LongInt;
  end;

var
  p: TPoint3D;
begin
  p.x := 10; p.y := 20; p.z := 30; p.w := 40;
  with p do
    begin
      if x <> 10 then halt(1);
      if y <> 20 then halt(2);
      if z <> 30 then halt(3);
      if w <> 40 then halt(4);
    end;
end.
