program if_expr_assigning_record_01;

{$mode unleashed}

type
  TPair = record
    a, b: Integer;
  end;

function MakeA: TPair;
begin
  Result.a := 1; Result.b := 2;
end;

function MakeB: TPair;
begin
  Result.a := 100; Result.b := 200;
end;

begin
  for var which := false to true do
  begin
    var p: TPair := if which then MakeA else MakeB;
    if which and (p.a <> 1)   then halt(1);
    if (not which) and (p.a <> 100) then halt(2);
  end;
end.
