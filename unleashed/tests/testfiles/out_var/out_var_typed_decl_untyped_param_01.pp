program out_var_typed_decl_untyped_param_01;
{$mode unleashed}

// annotation is the way to bind an untyped var parameter:
// the callee sees a zeroed variable of the annotated type
procedure grab(var buf);
begin
  if pinteger(@buf)^ <> 0 then Halt(1);
  pinteger(@buf)^ := 7;
end;

begin
  grab(var n: integer);
  if n <> 7 then Halt(2);
end.
