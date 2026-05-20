program composable_records_wild_two_embeds_with_methods_01;

{$mode unleashed}

type
  TInner = record
    val: LongInt;
    function Doubled: LongInt;
  end;

  TOuter = record
    embed TInner;
    extra: Byte;
  end;

function TInner.Doubled: LongInt;
begin
  Result := val * 2;
end;

var
  r: TOuter;
begin
  r.val := 21;
  r.extra := 7;
  { method auto-flatten: r.Doubled reaches through the anonymous embed }
  if r.Doubled <> 42 then halt(1);
  { typename-qualified access also works }
  if r.TInner.Doubled <> 42 then halt(2);
  if r.extra <> 7 then halt(3);
end.
