program composable_records_visibility_private_same_unit_01;

{$mode unleashed}

type
  TInternal = record
  private
    secret: LongInt;
  public
    visible: LongInt;
  end;

  TWrapper = record
    embed TInternal;
  end;

var
  w: TWrapper;
begin
  { same unit: `private` fields of TInternal are reachable via the
    flat path because the access site is in TInternal's unit }
  w.secret := 42;
  w.visible := 99;
  if w.secret <> 42 then halt(1);
  if w.visible <> 99 then halt(2);
end.
