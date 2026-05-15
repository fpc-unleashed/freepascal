program composable_records_operator_through_embed_04;
{ unary operator through embed: `-a` on TLabelled finds the unary `-`
  defined on the embedded TVec, returning a TVec. }

{$mode unleashed}

type
  TVec = record
    x, y: Integer;
    class operator - (a: TVec): TVec;
  end;
  TLabelled = record
    embed TVec;
    tag: AnsiString;
  end;

class operator TVec.- (a: TVec): TVec;
begin
  result.x := -a.x;
  result.y := -a.y;
end;

var
  a: TLabelled;
  r: TVec;
begin
  a.x := 3; a.y := 4;
  r := -a;
  if r.x <> -3 then halt(1);
  if r.y <> -4 then halt(2);
end.
