program implicit_generics_class_01;

{$mode unleashed}
{$modeswitch implicitgenerics}

type
  TBox<T> = class
  private
    FValue: T;
  public
    constructor Create(AValue: T);
    property Value: T read FValue;
  end;

constructor TBox<T>.Create(AValue: T);
begin
  FValue := AValue;
end;

begin
  var b := autofree TBox<Integer>.Create(42);
  if b.Value <> 42 then halt(1);

  var s := autofree TBox<String>.Create('hello');
  if s.Value <> 'hello' then halt(2);
end.
