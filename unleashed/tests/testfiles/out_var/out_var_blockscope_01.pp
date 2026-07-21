program out_var_blockscope_01;
{$mode unleashed}

procedure getval(out x: integer);
begin
  x := 5;
end;

procedure run;
begin
  begin
    getval(var inner);
    if inner <> 5 then Halt(1);
  end;
end;

begin
  run;
end.
