program out_var_typed_decl_untyped_seed_01;
{$mode unleashed}

// seeded annotated declaration at an untyped var parameter
procedure bump(var buf);
begin
  if pinteger(@buf)^ <> 123 then Halt(1);
  inc(pinteger(@buf)^);
end;

begin
  bump(var n: integer := 123);
  if n <> 124 then Halt(2);
end.
