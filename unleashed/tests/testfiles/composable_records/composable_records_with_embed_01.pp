program composable_records_with_embed_01;

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
  d: TDerived;
begin
  d.x := 1; d.y := 2; d.z := 3;
  with d do
    begin
      if x <> 1 then halt(1);
      if y <> 2 then halt(2);
      if z <> 3 then halt(3);
    end;
end.
