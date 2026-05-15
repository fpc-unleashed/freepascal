program composable_records_inline_var_pad_01;

{$mode unleashed}

procedure main;
begin
  var r: bitpacked record of Byte
    a: 3;
    pad 5;
    b: 8;
  end;
  r.a := 7;
  r.b := $aa;
  if r.a <> 7 then halt(1);
  if r.b <> $aa then halt(2);
  if SizeOf(r) <> 2 then halt(3);
end;

begin
  main;
end.
