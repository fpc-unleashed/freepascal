{ Integer (POD_4) and Double (a float kept out of the POD buckets) are
  different shapes, so the modeswitch
  must remain a sound no-op for them. each Integer/Double specialization
  keeps its own body and its own data; no crosstalk allowed }
program lightgenerics_shape_pod_no_share_04;
{$mode unleashed}
{$modeswitch lightgenerics}

type
  TCell<T>=class(TObject)
    FValue: T;
    procedure Put(const A: T);
    function Get: T;
  end;

procedure TCell<T>.Put(const A: T);
begin
  FValue := A;
end;

function TCell<T>.Get: T;
begin
  Result := FValue;
end;

type
  TIntCell = TCell<Integer>;
  TDblCell = TCell<Double>;

var
  ci: TIntCell;
  cd: TDblCell;
begin
  ci := TIntCell.Create;
  cd := TDblCell.Create;
  ci.Put(42);
  cd.Put(3.5);
  if ci.Get <> 42 then Halt(1);
  if cd.Get <> 3.5 then Halt(2);
  ci.Free;
  cd.Free;
end.
