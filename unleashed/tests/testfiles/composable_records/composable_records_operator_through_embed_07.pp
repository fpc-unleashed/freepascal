program composable_records_operator_through_embed_07;
{ typename-qualified path remains explicit: `a.TVec + b.TVec` is the
  manual form of what auto-flatten produces, compiles to the same call. }

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
  a, b: TLabelled;
  r1, r2: TVec;
begin
  a.x := 7; a.y := 8;
  b.x := 1; b.y := 2;
  r1 := a + b;
  r2 := a.TVec + b.TVec;
  if (r1.x <> r2.x) or (r1.y <> r2.y) then halt(1);
  if (r1.x <> 8) or (r1.y <> 10) then halt(2);
end.
