program composable_records_typecast_size_equal_01;
{ size-equal record typecast through an embed: TOuter has only `embed TInner;`,
  so sizeof(TOuter) = sizeof(TInner), and TInner(o) is a plain record-to-record
  cast that stock FPC already accepts. composable records inherit the same rule. }

{$mode unleashed}

type
  TInner = record
    x, y: Integer;
  end;
  TOuter = record
    embed TInner;
  end;

procedure use_inner(const i: TInner);
begin
  if i.x <> 11 then halt(1);
  if i.y <> 22 then halt(2);
end;

var
  o: TOuter;
begin
  o.x := 11; o.y := 22;
  use_inner(TInner(o));
end.
