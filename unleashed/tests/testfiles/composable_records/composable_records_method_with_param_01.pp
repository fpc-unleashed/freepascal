program composable_records_method_with_param_01;

{$mode unleashed}

type
  TInner = record
    base: LongInt;
    function Plus(n: LongInt): LongInt;
    function Times(a, b: LongInt): LongInt;
  end;

  TOuter = record
    embed TInner;
  end;

function TInner.Plus(n: LongInt): LongInt;
begin
  Result := base + n;
end;

function TInner.Times(a, b: LongInt): LongInt;
begin
  Result := base * a * b;
end;

var
  r: TOuter;
begin
  r.base := 10;
  if r.Plus(5) <> 15 then halt(1);
  if r.Times(2, 3) <> 60 then halt(2);
end.
