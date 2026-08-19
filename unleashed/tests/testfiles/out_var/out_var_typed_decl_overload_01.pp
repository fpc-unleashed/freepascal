program out_var_typed_decl_overload_01;
{$mode unleashed}

// the annotation resolves an overload pair a bare `var x` cannot
procedure take(out x: integer); overload;
begin
  x := 1;
end;

procedure take(out x: string); overload;
begin
  x := 'str';
end;

begin
  take(var n: integer);
  if n <> 1 then Halt(1);

  take(var s: string);
  if s <> 'str' then Halt(2);
end.
