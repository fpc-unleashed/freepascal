program composable_records_typed_const_embed_flatten_01;

{$mode unleashed}

type
  TBase = record
    x, y: Integer;
  end;
  TDerived = record
    embed TBase;
    z: Integer;
  end;

const
  k: TDerived = (x: 10; y: 20; z: 30);

procedure check_inline_var;
begin
  var v: TDerived := (x: 100; y: 200; z: 300);
  if v.x <> 100 then halt(4);
  if v.y <> 200 then halt(5);
  if v.z <> 300 then halt(6);
end;

begin
  if k.x <> 10 then halt(1);
  if k.y <> 20 then halt(2);
  if k.z <> 30 then halt(3);
  check_inline_var;
end.
