{ %FAIL %OPT=-Sew }
program composable_records_fail_inline_var_partial_init_01;
{ aggregate init of an inline-var record must mention every field;
  with -Sew the "some fields ... not initialized" warning becomes
  an error. covers the partial-init path under composable records
  body parser. }

{$mode unleashed}

procedure main;
begin
  var z: record
    a, b, c: Integer;
  end := (a: 1; b: 2);
  WriteLn(z.a, ' ', z.b, ' ', z.c);
end;

begin
  main;
end.
