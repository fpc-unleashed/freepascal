{ basic shape-Ref sharing: three class specializations of the same generic
  must keep their value identity after the body is shared }
program lightgenerics_shape_ref_basic_01;
{$mode unleashed}
{$modeswitch lightgenerics}

type
  TBox<T>=class(TObject)
    FValue: T;
    procedure SetValue(const AValue: T);
    function GetValue: T;
  end;

procedure TBox<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
end;

function TBox<T>.GetValue: T;
begin
  Result := FValue;
end;

type
  TFoo = class end;
  TBar = class end;
  TBaz = class end;

  TBoxFoo = TBox<TFoo>;
  TBoxBar = TBox<TBar>;
  TBoxBaz = TBox<TBaz>;

var
  bf: TBoxFoo;
  bb: TBoxBar;
  bz: TBoxBaz;
  f: TFoo;
  b: TBar;
  z: TBaz;
begin
  f := TFoo.Create;
  b := TBar.Create;
  z := TBaz.Create;
  bf := TBoxFoo.Create;
  bb := TBoxBar.Create;
  bz := TBoxBaz.Create;
  bf.SetValue(f);
  bb.SetValue(b);
  bz.SetValue(z);
  if bf.GetValue <> f then Halt(1);
  if bb.GetValue <> b then Halt(2);
  if bz.GetValue <> z then Halt(3);
end.
