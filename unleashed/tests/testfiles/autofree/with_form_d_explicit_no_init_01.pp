program with_form_d_explicit_no_init_01;

{$mode unleashed}

type
  TPoint = record
    a, b: Integer;
  end;

procedure FillIt(var p: TPoint);
begin
  p.a := 10;
  p.b := 20;
end;

begin
  // Form D: inline var with explicit type, no initializer (stack-allocated)
  with var t: TPoint do
  begin
    t.a := 1;
    t.b := 2;
    if t.a <> 1 then halt(1);
    if t.b <> 2 then halt(2);
    FillIt(t);
    if t.a <> 10 then halt(3);
  end;
end.
