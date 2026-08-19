{ %FAIL }
program out_var_fail_typed_decl_mismatch_01;
{$mode unleashed}

procedure setName(out s: string);
begin
  s := 'foo';
end;

begin
  // the annotated type must equal the parameter type
  setName(var n: integer);
end.
