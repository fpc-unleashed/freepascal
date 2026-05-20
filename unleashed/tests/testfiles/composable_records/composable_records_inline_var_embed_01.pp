program composable_records_inline_var_embed_01;

{$mode unleashed}

type
  TBase = record
    x, y: Integer;
  end;

  TDerived = record
    embed TBase;
    z: Integer;
  end;

procedure main;
begin
  var d := Default(TDerived);
  d.x := 10;
  d.y := 20;
  d.z := 30;
  if d.x <> 10 then halt(1);
  if d.y <> 20 then halt(2);
  if d.z <> 30 then halt(3);
end;

begin
  main;
end.
