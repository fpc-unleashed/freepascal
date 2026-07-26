program SwapValues_property_instance_once_19;
{$mode unleashed}
// a side-effecting instance expression runs once for the whole swap
type
  TBox = class
  public
    FVal: Integer;
    function GetVal: Integer;
    procedure SetVal(v: Integer);
    property Val: Integer read GetVal write SetVal;
  end;

var
  b: TBox;
  x: Integer;
  objcalls: Integer;

function TBox.GetVal: Integer; begin Result := FVal; end;
procedure TBox.SetVal(v: Integer); begin FVal := v; end;

function GetBox: TBox;
begin
  Inc(objcalls);
  Result := b;
end;

begin
  b := TBox.Create;
  b.FVal := 5;
  x := 7;
  objcalls := 0;
  SwapValues(GetBox.Val, x);
  if objcalls <> 1 then halt(1);
  if b.FVal <> 7 then halt(2);
  if x <> 5 then halt(3);
  b.Free;
end.
