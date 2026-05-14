program composable_records_wild_visibility_01;

{$mode unleashed}

type
  TInner = record
    a: LongInt;
  end;

  TRec = record
  private
    embed TInner;
  public
    b: LongInt;
  end;

  THelper = record helper for TRec
    procedure SetA(v: LongInt);
  end;

procedure THelper.SetA(v: LongInt);
begin
  Self.a := v;        { reachable from within helper / record scope }
end;

var
  r: TRec;
begin
  r.SetA(42);
  r.b := 7;
  if r.b <> 7 then halt(1);
end.
