{ specializations whose type parameters all classify as
  Shape_POD_4 (Integer, LongWord, Single all sit in this bucket)
  share one method body. proof: identical TMethod.Code across
  TCell<Integer> and TCell<LongWord> }
program lightgenerics_shape_pod4_share_06;
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
  TCardCell = TCell<LongWord>;

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

procedure PickCard(out p: Pointer);
var
  o: TCardCell;
  m: TMethod;
begin
  o := TCardCell.Create;
  m := TMethod(@o.Put);
  p := m.Code;
  o.Free;
end;

var
  pi, pc: Pointer;
begin
  PickInt(pi);
  PickCard(pc);
  if pi = nil then Halt(10);
  if pc = nil then Halt(11);
  if pi <> pc then Halt(1);
end.
