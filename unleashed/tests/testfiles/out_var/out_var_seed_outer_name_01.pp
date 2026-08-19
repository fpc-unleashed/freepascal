program out_var_seed_outer_name_01;
{$mode unleashed}

procedure twice(var a: integer);
begin
  a := a * 2;
end;

var q: integer = 5;
begin
  begin
    // the outer q is still visible in the seed; the new q shadows it afterwards
    twice(var q := q + 1);
    if q <> 12 then halt(1);
  end;
  if q <> 5 then halt(2);
  writeln('ok');
end.
