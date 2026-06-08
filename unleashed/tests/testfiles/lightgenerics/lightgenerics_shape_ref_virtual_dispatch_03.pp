{ shared body in the base specialization must not break virtual dispatch
  to a descendant's override. each specialization's vmt is private even
  when its method bodies are shared }
program lightgenerics_shape_ref_virtual_dispatch_03;
{$mode unleashed}
{$modeswitch lightgenerics}

type
  TBase<T>=class(TObject)
    FValue: T;
    procedure Stamp; virtual;
  end;

procedure TBase<T>.Stamp;
begin
  { base does nothing - descendant overrides }
end;

type
  TFoo = class end;
  TBar = class end;

  TFooHolder = class(TBase<TFoo>)
    Called: Integer;
    procedure Stamp; override;
  end;

  TBarHolder = class(TBase<TBar>)
    Called: Integer;
    procedure Stamp; override;
  end;

procedure TFooHolder.Stamp;
begin
  Called := Called + 100;
end;

procedure TBarHolder.Stamp;
begin
  Called := Called + 200;
end;

var
  fh: TFooHolder;
  bh: TBarHolder;
begin
  fh := TFooHolder.Create;
  bh := TBarHolder.Create;
  fh.Stamp;
  bh.Stamp;
  if fh.Called <> 100 then Halt(1);
  if bh.Called <> 200 then Halt(2);
  fh.Free;
  bh.Free;
end.
