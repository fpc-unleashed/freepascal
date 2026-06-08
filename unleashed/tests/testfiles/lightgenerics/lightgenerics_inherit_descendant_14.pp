{ a non-generic class can derive from a lightgenerics
  specialization and override its methods. the descendant's vmt
  slot for the inherited method still resolves to the canonical
  shared body, and inherited calls work as expected }
program lightgenerics_inherit_descendant_14;
{$mode unleashed}
{$modeswitch lightgenerics}

type
  TBase<T>=class(TObject)
    FValue: T;
    procedure Put(const A: T); virtual;
  end;

procedure TBase<T>.Put(const A: T);
begin
  FValue := A;
end;

type
  TFoo = class end;

  TDescendant = class(TBase<TFoo>)
    Stamp: Integer;
    procedure Put(const A: TFoo); override;
  end;

procedure TDescendant.Put(const A: TFoo);
begin
  inherited Put(A);
  Stamp := 42;
end;

var
  d: TDescendant;
  f: TFoo;
begin
  f := TFoo.Create;
  d := TDescendant.Create;
  d.Put(f);
  if d.FValue <> f then Halt(1);
  if d.Stamp <> 42 then Halt(2);
  d.Free;
  f.Free;
end.
