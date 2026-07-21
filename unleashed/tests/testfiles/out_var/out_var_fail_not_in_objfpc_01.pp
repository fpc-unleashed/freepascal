{ %FAIL }
program out_var_fail_not_in_objfpc_01;
{$mode objfpc}{$h+}

procedure getval(out x: integer);
begin
  x := 1;
end;

begin
  // without the outvar modeswitch, `var` at an argument is a syntax error
  getval(var y);
end.
