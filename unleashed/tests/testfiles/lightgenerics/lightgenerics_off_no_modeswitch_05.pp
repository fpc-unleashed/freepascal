{ without the modeswitch, generics fall back to stock monomorphization
  and stay fully functional. this is a sanity check that adding the
  modeswitch infrastructure did not regress the default path }
program lightgenerics_off_no_modeswitch_05;
{$mode unleashed}

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
  TBoxFoo = TBox<TFoo>;

var
  bf: TBoxFoo;
  f: TFoo;
begin
  f := TFoo.Create;
  bf := TBoxFoo.Create;
  bf.SetValue(f);
  if bf.GetValue <> f then Halt(1);
  bf.Free;
  f.Free;
end.
