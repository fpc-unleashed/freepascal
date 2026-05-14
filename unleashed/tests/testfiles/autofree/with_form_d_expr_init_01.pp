program with_form_d_expr_init_01;

{$mode unleashed}

type
  TPoint = record
    a, b: Integer;
  end;

function MakeSrc: TPoint;
begin
  Result.a := 7;
  Result.b := 9;
end;

begin
  with var p: TPoint := MakeSrc do
  begin
    if p.a <> 7 then halt(1);
    if p.b <> 9 then halt(2);
  end;
end.
