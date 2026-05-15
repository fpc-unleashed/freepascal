program composable_records_operator_through_embed_08;
{ cascade for a unary operator: A embeds B, B embeds C, unary `-`
  defined on C. lookup walks two carriers and rewrites the operand. }

{$mode unleashed}

type
  TInner = record
    v: Integer;
    class operator - (a: TInner): TInner;
  end;
  TMid = record
    embed TInner;
  end;
  TOuter = record
    embed TMid;
  end;

class operator TInner.- (a: TInner): TInner;
begin
  result.v := -a.v;
end;

var
  a: TOuter;
  r: TInner;
begin
  a.v := 7;
  r := -a;
  if r.v <> -7 then halt(1);
end.
