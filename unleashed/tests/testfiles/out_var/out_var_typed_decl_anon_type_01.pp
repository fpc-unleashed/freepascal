program out_var_typed_decl_anon_type_01;
{$mode unleashed}

// the annotation accepts anonymous types, here at an untyped parameter
procedure stamp(var buf);
var p: pbyte;
begin
  p := pbyte(@buf);
  p^ := $AB;
  inc(p, 3);
  p^ := $CD;
end;

begin
  stamp(var raw: array[0..3] of byte);
  if (raw[0] <> $AB) or (raw[1] <> 0) or (raw[3] <> $CD) then Halt(1);
end.
