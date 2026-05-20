program composable_records_wild_assign_var_path_01;

{$mode unleashed}

type
  TInner = record
    a: LongInt;
    b: LongInt;
  end;

  TOuter = record
    embed TInner;
    c: LongInt;
  end;

procedure setit(var x: LongInt);
begin
  x := 999;
end;

var
  r: TOuter;
begin
  r.a := 0;
  setit(r.a);             { var-param through flattened path }
  if r.a <> 999 then halt(1);
  setit(r.c);
  if r.c <> 999 then halt(2);
end.
