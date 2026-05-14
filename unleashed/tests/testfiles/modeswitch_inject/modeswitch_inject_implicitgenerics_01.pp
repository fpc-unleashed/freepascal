program modeswitch_inject_implicitgenerics_01;

{$mode unleashed}
{$modeswitch implicitgenerics}

// without {$modeswitch implicitgenerics}, plain `<T>` syntax outside
// {$mode delphi} is rejected
type
  TBox<T> = class
  private
    FValue: T;
  public
    property Value: T read FValue;
  end;

var
  b: TBox<Integer>;

begin
  b := TBox<Integer>.Create;
  b.Free;
end.
