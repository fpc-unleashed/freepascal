{ proof of sharing: two specializations of the same shape-Ref generic
  return the same method code address. without lightgenerics each
  specialization would own a private body at a distinct address }
program lightgenerics_shape_ref_method_ptr_02;
{$mode unleashed}
{$modeswitch lightgenerics}

type
  TBox<T>=class(TObject)
    FValue: T;
    procedure SetValue(const AValue: T); virtual;
  end;

procedure TBox<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
end;

type
  TFoo = class end;
  TBar = class end;

  TBoxFoo = TBox<TFoo>;
  TBoxBar = TBox<TBar>;

procedure PickFoo(out p: Pointer);
var
  o: TBoxFoo;
  m: TMethod;
begin
  o := TBoxFoo.Create;
  m := TMethod(@o.SetValue);
  p := m.Code;
  o.Free;
end;

procedure PickBar(out p: Pointer);
var
  o: TBoxBar;
  m: TMethod;
begin
  o := TBoxBar.Create;
  m := TMethod(@o.SetValue);
  p := m.Code;
  o.Free;
end;

var
  pf, pb: Pointer;
begin
  PickFoo(pf);
  PickBar(pb);
  if pf = nil then Halt(10);
  if pb = nil then Halt(11);
  if pf <> pb then Halt(1);
end.
