program composable_records_inline_var_default_init_01;

{$mode unleashed}

type
  TBase = record
    x, y: Integer;
  end;

  TFoo = record
    embed TBase;
    extra: Integer;
  end;

procedure main;
begin
  { inferred type from Default(TFoo) - composition carries through }
  var z := Default(TFoo);
  if z.x <> 0 then halt(1);
  if z.y <> 0 then halt(2);
  if z.extra <> 0 then halt(3);
  z.x := 42;
  z.extra := 99;
  if z.x <> 42 then halt(4);
  if z.extra <> 99 then halt(5);
end;

begin
  main;
end.
