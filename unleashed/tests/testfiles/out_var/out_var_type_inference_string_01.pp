program out_var_type_inference_string_01;
{$mode unleashed}

procedure getstr(out s: string);
begin
  s := 'inferred';
end;

begin
  getstr(var captured);
  if captured <> 'inferred' then Halt(1);
  if Length(captured) <> 8 then Halt(2);
end.
