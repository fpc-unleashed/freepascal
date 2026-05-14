program inc_dec_property_enum_01;

{$mode unleashed}

type
  TMode = (mIdle, mWarmup, mRunning, mStopping, mDone);

  TFsm = class
  private
    FState: TMode;
    function GetState: TMode;
    procedure SetState(v: TMode);
  public
    property State: TMode read GetState write SetState;
  end;

function TFsm.GetState: TMode;
begin
  Result := FState;
end;

procedure TFsm.SetState(v: TMode);
begin
  FState := v;
end;

begin
  var f := autofree TFsm.Create;
  f.State := mIdle;
  Inc(f.State);
  if f.State <> mWarmup then halt(1);
  Inc(f.State, 2);
  if f.State <> mStopping then halt(2);
  Dec(f.State);
  if f.State <> mRunning then halt(3);
end.
