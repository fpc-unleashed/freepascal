program composable_records_method_qualified_by_typename_01;

{$mode unleashed}

type
  TInner = record
    val: LongInt;
    function Doubled: LongInt;
  end;

  TOuter = record
    embed TInner;
  end;

function TInner.Doubled: LongInt;
begin
  Result := val * 2;
end;

var
  r: TOuter;
begin
  r.val := 21;
  { Pascal-style typename qualification of the embedded type works
    alongside the flat path - both reach the same method }
  if r.TInner.Doubled <> 42 then halt(1);
  if r.TInner.val <> 21 then halt(2);
  if r.Doubled <> 42 then halt(3);
end.
