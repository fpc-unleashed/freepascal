program composable_records_operator_through_embed_02;
{ operator result assigned through the embed slice: `c.TVec := a + b`
  updates only the flattened TVec fields, leaving the outer-only
  fields untouched. }

{$mode unleashed}

type
  TVec = record
    x, y: Integer;
    class operator + (a, b: TVec): TVec;
  end;
  TLabelled = record
    embed TVec;
    tag: AnsiString;
  end;

class operator TVec.+ (a, b: TVec): TVec;
begin
  result.x := a.x + b.x;
  result.y := a.y + b.y;
end;

var
  a, b, c: TLabelled;
begin
  a.x := 1; a.y := 2;
  b.x := 3; b.y := 4;
  c.tag := 'before';
  c.TVec := a + b;
  if c.x <> 4 then halt(1);
  if c.y <> 6 then halt(2);
  if c.tag <> 'before' then halt(3);
end.
