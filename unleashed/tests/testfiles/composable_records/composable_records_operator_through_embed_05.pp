program composable_records_operator_through_embed_05;
{ comparison operators through embed: `=` and `<>` on TLabelled use
  the `=` defined on the embedded TVec. }

{$mode unleashed}

type
  TVec = record
    x, y: Integer;
    class operator = (a, b: TVec): Boolean;
  end;
  TLabelled = record
    embed TVec;
    tag: AnsiString;
  end;

class operator TVec.= (a, b: TVec): Boolean;
begin
  result := (a.x = b.x) and (a.y = b.y);
end;

var
  a, b: TLabelled;
begin
  a.x := 1; a.y := 2; a.tag := 'A';
  b.x := 1; b.y := 2; b.tag := 'B';
  if not (a = b) then halt(1);
  b.x := 99;
  if (a = b) then halt(2);
  if not (a <> b) then halt(3);
end.
