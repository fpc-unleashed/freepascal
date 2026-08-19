{ %FAIL }
program out_var_fail_ambiguous_out_var_overload_01;
{$mode unleashed}

procedure pick(out x: integer); overload;
begin
  x := 1;
end;

procedure pick(var x: string); overload;
begin
  x := x + '!';
end;

begin
  // an unseeded `var x` matches both the out and the var overload: ambiguous
  pick(var z);
end.
