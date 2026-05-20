program composable_records_pointer_inline_anon_01;

{$mode unleashed}

type
  TPoint3D = record
    record
      x, y, z: LongInt;
    end;
    w: LongInt;
  end;
  PPoint3D = ^TPoint3D;

var
  p: PPoint3D;
begin
  New(p);
  try
    p^.x := 10;
    p^.y := 20;
    p^.z := 30;
    p^.w := 40;
    if p^.x <> 10 then halt(1);
    if p^.y <> 20 then halt(2);
    if p^.z <> 30 then halt(3);
    if p^.w <> 40 then halt(4);
  finally
    Dispose(p);
  end;
end.
