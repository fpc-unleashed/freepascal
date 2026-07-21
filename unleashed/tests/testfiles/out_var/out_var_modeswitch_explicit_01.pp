program out_var_modeswitch_explicit_01;
{$mode objfpc}{$h+}
{$modeswitch outvar}

procedure getval(out x: integer);
begin
  x := 7;
end;

begin
  // the feature works outside unleashed when the modeswitch is enabled directly
  getval(var y);
  if y <> 7 then Halt(1);
end.
