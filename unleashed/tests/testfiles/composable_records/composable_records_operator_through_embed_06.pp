program composable_records_operator_through_embed_06;
{ cascade: A embeds B, B embeds C, operator on C. lookup walks
  composition chain through both carriers. }

{$mode unleashed}

type
  TInner = record
    v: Integer;
    class operator + (a, b: TInner): TInner;
  end;
  TMid = record
    embed TInner;
    pad: Integer;
  end;
  TOuter = record
    embed TMid;
    tag: AnsiString;
  end;

class operator TInner.+ (a, b: TInner): TInner;
begin
  result.v := a.v + b.v;
end;

var
  a, b: TOuter;
  r: TInner;
begin
  a.v := 10;
  b.v := 5;
  r := a + b;
  if r.v <> 15 then halt(1);
end.
