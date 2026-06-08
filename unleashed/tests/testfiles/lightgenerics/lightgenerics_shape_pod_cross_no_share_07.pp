{ POD shapes only share within their own size bucket.
  TCell<Integer> (POD_4) and TCell<Int64> (POD_8) must NOT share
  their Put bodies because the monomorphized machine code differs
  (32-bit move vs 64-bit move) }
program lightgenerics_shape_pod_cross_no_share_07;
{$mode unleashed}
{$modeswitch lightgenerics}

type
  TCell<T>=class(TObject)
    FValue: T;
    procedure Put(const A: T); virtual;
  end;

procedure TCell<T>.Put(const A: T);
begin
  FValue := A;
end;

type
  TIntCell  = TCell<Integer>;
  TInt64Cell = TCell<Int64>;

procedure PickInt(out p: Pointer);
var
  o: TIntCell;
  m: TMethod;
begin
  o := TIntCell.Create;
  m := TMethod(@o.Put);
  p := m.Code;
  o.Free;
end;

procedure PickInt64(out p: Pointer);
var
  o: TInt64Cell;
  m: TMethod;
begin
  o := TInt64Cell.Create;
  m := TMethod(@o.Put);
  p := m.Code;
  o.Free;
end;

var
  pi, pq: Pointer;
begin
  PickInt(pi);
  PickInt64(pq);
  if pi = nil then Halt(10);
  if pq = nil then Halt(11);
  if pi = pq then Halt(1);
end.
