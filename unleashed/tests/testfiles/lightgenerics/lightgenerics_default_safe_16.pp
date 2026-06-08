{ Default(T) is byte-identical across same-shape specializations
  (always a zeroed memory cell of T's size), so sharing remains correct
  and no fallback to monomorph is needed }
program lightgenerics_default_safe_16;
{$mode unleashed}
{$modeswitch lightgenerics}

type
  TCell<T>=class(TObject)
    FValue: T;
    procedure Reset;
  end;

procedure TCell<T>.Reset;
begin
  FValue := Default(T);
end;

type
  TFoo = class end;
  TBar = class end;

  TCellFoo = TCell<TFoo>;
  TCellBar = TCell<TBar>;

procedure PickFoo(out p: Pointer);
var o: TCellFoo; m: TMethod;
begin o:=TCellFoo.Create; m:=TMethod(@o.Reset); p:=m.Code; o.Free; end;

procedure PickBar(out p: Pointer);
var o: TCellBar; m: TMethod;
begin o:=TCellBar.Create; m:=TMethod(@o.Reset); p:=m.Code; o.Free; end;

var
  pf, pb: Pointer;
  cf: TCellFoo;
  cb: TCellBar;
  f: TFoo;
begin
  PickFoo(pf);
  PickBar(pb);
  if pf <> pb then Halt(1);

  f := TFoo.Create;
  cf := TCellFoo.Create;
  cf.FValue := f;
  if cf.FValue <> f then Halt(2);
  cf.Reset;
  if cf.FValue <> nil then Halt(3);
  cb := TCellBar.Create;
  cb.Reset;
  if cb.FValue <> nil then Halt(4);

  cf.Free;
  cb.Free;
  f.Free;
end.
