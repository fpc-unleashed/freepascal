{ generic records (not classes) ride the same dedup path
  as classes. TBox<TFoo>=record and TBox<TBar>=record share one
  SetValue body keyed by the canonical mangle }
program lightgenerics_record_shape_ref_10;
{$mode unleashed}
{$modeswitch lightgenerics}

type
  TBox<T>=record
    FValue: T;
    procedure SetValue(const A: T);
    function GetValue: T;
  end;

procedure TBox<T>.SetValue(const A: T);
begin
  FValue := A;
end;

function TBox<T>.GetValue: T;
begin
  Result := FValue;
end;

type
  TFoo = class end;
  TBar = class end;

  TBoxFoo = TBox<TFoo>;
  TBoxBar = TBox<TBar>;

var
  bf: TBoxFoo;
  bb: TBoxBar;
  f: TFoo; b: TBar;
begin
  f := TFoo.Create;
  b := TBar.Create;
  bf.SetValue(f);
  bb.SetValue(b);
  if bf.GetValue <> f then Halt(1);
  if bb.GetValue <> b then Halt(2);
  f.Free;
  b.Free;
end.
