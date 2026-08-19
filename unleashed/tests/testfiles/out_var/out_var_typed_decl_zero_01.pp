program out_var_typed_decl_zero_01;
{$mode unleashed}

// annotated declaration at a matching typed var parameter:
// same zero-init as the bare form
procedure addTo(var acc: integer; n: integer);
begin
  if acc <> 0 then Halt(1);
  acc := acc + n;
end;

begin
  addTo(var x: integer, 5);
  if x <> 5 then Halt(2);
end.
