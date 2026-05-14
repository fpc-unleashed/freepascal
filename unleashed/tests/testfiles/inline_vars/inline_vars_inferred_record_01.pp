program inline_vars_inferred_record_01;

{$mode unleashed}

type
  TPair = record
    a, b: Integer;
  end;

function Make(a, b: Integer): TPair;
begin
  Result.a := a;
  Result.b := b;
end;

begin
  var p := Make(7, 9);
  if p.a <> 7 then halt(1);
  if p.b <> 9 then halt(2);
end.
