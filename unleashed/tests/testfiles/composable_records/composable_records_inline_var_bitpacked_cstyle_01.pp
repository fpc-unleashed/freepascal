program composable_records_inline_var_bitpacked_cstyle_01;

{$mode unleashed}

procedure main;
begin
  var flags: bitpacked record of Byte
    a: 3;
    b: 5;
  end;
  flags.a := 5;
  flags.b := 17;
  if flags.a <> 5 then halt(1);
  if flags.b <> 17 then halt(2);
  if SizeOf(flags) <> 1 then halt(3);
end;

begin
  main;
end.
