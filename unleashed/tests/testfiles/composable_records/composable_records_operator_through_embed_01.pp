program composable_records_operator_through_embed_01;
{ basic binary operator through embed: `a + b` on TLabelled finds
  the `+` defined on the embedded TVec, returning a TVec result. }

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
  r: TVec;
begin
  a.x := 1; a.y := 2;
  b.x := 3; b.y := 4;
  r := a + b;
  if r.x <> 4 then halt(1);
  if r.y <> 6 then halt(2);
end.
