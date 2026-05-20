program composable_records_pointer_deref_01;

{$mode unleashed}

type
  TBase = record
    x, y: Integer;
  end;
  TDerived = record
    embed TBase;
    z: Integer;
  end;
  PDerived = ^TDerived;

var
  p: PDerived;
begin
  New(p);
  try
    p^.x := 1;
    p^.y := 2;
    p^.z := 3;
    if p^.x <> 1 then halt(1);
    if p^.y <> 2 then halt(2);
    if p^.z <> 3 then halt(3);
  finally
    Dispose(p);
  end;
end.
