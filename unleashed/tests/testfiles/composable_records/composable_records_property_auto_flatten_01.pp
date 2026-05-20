program composable_records_property_auto_flatten_01;

{$mode unleashed}

type
  TInner = record
  private
    fVal: LongInt;
    function GetVal: LongInt;
    procedure SetVal(v: LongInt);
  public
    property Val: LongInt read GetVal write SetVal;
  end;

  TOuter = record
    embed TInner;
    tail: Byte;
  end;

function TInner.GetVal: LongInt;
begin
  Result := fVal;
end;

procedure TInner.SetVal(v: LongInt);
begin
  fVal := v * 10;
end;

var
  r: TOuter;
begin
  r.Val := 5;
  if r.Val <> 50 then halt(1);
end.
