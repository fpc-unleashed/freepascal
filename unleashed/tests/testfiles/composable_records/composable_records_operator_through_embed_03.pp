program composable_records_operator_through_embed_03;
{ multiple binary operators on the embedded type all auto-flatten:
  `+`, `-`, `*` (scalar multiply via class operator). }

{$mode unleashed}

type
  TVec = record
    x, y: Integer;
    class operator + (a, b: TVec): TVec;
    class operator - (a, b: TVec): TVec;
    class operator * (a: TVec; k: Integer): TVec;
  end;
  TTagged = record
    embed TVec;
    id: Integer;
  end;

class operator TVec.+ (a, b: TVec): TVec;
begin
  result.x := a.x + b.x;
  result.y := a.y + b.y;
end;

class operator TVec.- (a, b: TVec): TVec;
begin
  result.x := a.x - b.x;
  result.y := a.y - b.y;
end;

class operator TVec.* (a: TVec; k: Integer): TVec;
begin
  result.x := a.x * k;
  result.y := a.y * k;
end;

var
  a, b: TTagged;
  r: TVec;
begin
  a.x := 10; a.y := 20;
  b.x := 1; b.y := 2;
  r := a + b;
  if (r.x <> 11) or (r.y <> 22) then halt(1);
  r := a - b;
  if (r.x <> 9) or (r.y <> 18) then halt(2);
  r := a * 3;
  if (r.x <> 30) or (r.y <> 60) then halt(3);
end.
