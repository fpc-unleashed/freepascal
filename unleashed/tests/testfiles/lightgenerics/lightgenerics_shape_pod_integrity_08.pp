{ runtime integrity of mixed POD specializations after
  shape-based sharing. each specialization keeps its own field
  storage and values do not bleed across types even though their
  bodies share machine code }
program lightgenerics_shape_pod_integrity_08;
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
  TIntCell   = TCell<Integer>;
  TCardCell  = TCell<LongWord>;
  TInt64Cell = TCell<Int64>;
  TDblCell   = TCell<Double>;

var
  ci: TIntCell;
  cc: TCardCell;
  cq: TInt64Cell;
  cd: TDblCell;
begin
  ci := TIntCell.Create;
  cc := TCardCell.Create;
  cq := TInt64Cell.Create;
  cd := TDblCell.Create;
  ci.Put(-42);
  cc.Put(99);
  cq.Put(12345678901234);
  cd.Put(3.14);
  if ci.Get <> -42 then Halt(1);
  if cc.Get <> 99 then Halt(2);
  if cq.Get <> 12345678901234 then Halt(3);
  if cd.Get <> 3.14 then Halt(4);
  ci.Free;
  cc.Free;
  cq.Free;
  cd.Free;
end.
