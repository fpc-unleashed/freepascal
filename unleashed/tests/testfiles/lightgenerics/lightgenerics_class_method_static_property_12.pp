{ class methods, static methods, property getter/setter
  bodies all join the dedup set. constructors and destructors still
  stay per-specialization }
program lightgenerics_class_method_static_property_12;
{$mode unleashed}
{$modeswitch lightgenerics}

type
  TBag<T>=class(TObject)
    FCount: Integer;
    FValue: T;
    class function Maker: T; static;
    procedure SetValue(const A: T);
    function GetValue: T;
    property Count: Integer read FCount write FCount;
    property Value: T read GetValue write SetValue;
  end;

class function TBag<T>.Maker: T;
begin
  Result := Default(T);
end;

procedure TBag<T>.SetValue(const A: T);
begin
  FValue := A;
end;

function TBag<T>.GetValue: T;
begin
  Result := FValue;
end;

type
  TFoo = class end;
  TBar = class end;

  TBagFoo = TBag<TFoo>;
  TBagBar = TBag<TBar>;

var
  bf: TBagFoo;
  bb: TBagBar;
  f: TFoo;
  b: TBar;
begin
  f := TFoo.Create;
  b := TBar.Create;
  bf := TBagFoo.Create;
  bb := TBagBar.Create;
  bf.Count := 42;
  bb.Count := 99;
  bf.Value := f;
  bb.Value := b;
  if bf.Count <> 42 then Halt(1);
  if bb.Count <> 99 then Halt(2);
  if bf.Value <> f then Halt(3);
  if bb.Value <> b then Halt(4);
  if TBagFoo.Maker <> nil then Halt(5);
  if TBagBar.Maker <> nil then Halt(6);
  bf.Free;
  bb.Free;
  f.Free;
  b.Free;
end.
