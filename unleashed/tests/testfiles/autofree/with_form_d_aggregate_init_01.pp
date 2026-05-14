program with_form_d_aggregate_init_01;

{$mode unleashed}

type
  TPoint = record
    a, b: Integer;
  end;

begin
  // Form D with record aggregate-literal init
  with var p: TPoint := (a: 1; b: 2) do
  begin
    if p.a <> 1 then halt(1);
    if p.b <> 2 then halt(2);
  end;
end.
