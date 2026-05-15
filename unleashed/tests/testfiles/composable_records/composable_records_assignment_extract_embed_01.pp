program composable_records_assignment_extract_embed_01;

{$mode unleashed}

type
  TBase = record
    x, y: Integer;
  end;
  TDerived = record
    embed TBase;
    z: Integer;
  end;

procedure use_base(const b: TBase; out got_x, got_y: Integer);
begin
  got_x := b.x;
  got_y := b.y;
end;

var
  d: TDerived;
  rx, ry: Integer;
begin
  d.x := 100;
  d.y := 200;
  d.z := 300;
  { pass TBase via flatten path - direct read of embedded fields }
  use_base(d.TBase, rx, ry);
  if rx <> 100 then halt(1);
  if ry <> 200 then halt(2);
end.
