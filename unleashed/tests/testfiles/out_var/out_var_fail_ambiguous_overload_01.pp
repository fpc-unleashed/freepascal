{ %FAIL }
program out_var_fail_ambiguous_overload_01;
{$mode unleashed}

procedure f(out x: integer); overload;
begin
  x := 1;
end;

procedure f(out x: string); overload;
begin
  x := 'a';
end;

begin
  // both overloads accept an out-var of any type at this position -> ambiguous
  f(var y);
end.
