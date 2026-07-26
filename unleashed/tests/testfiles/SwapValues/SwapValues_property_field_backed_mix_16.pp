program SwapValues_property_field_backed_mix_16;
{$mode unleashed}
// field-backed property with accessor property: the field side reads and
// writes the storage directly, the accessor side goes through its methods
type
  TBox = class
  public
    FA, FB: Integer;
    GetCalls, SetCalls: Integer;
    function GetA: Integer;
    procedure SetA(v: Integer);
    property A: Integer read GetA write SetA;
    property B: Integer read FB write FB;
  end;

function TBox.GetA: Integer; begin Inc(GetCalls); Result := FA; end;
procedure TBox.SetA(v: Integer); begin Inc(SetCalls); FA := v; end;

var
  b: TBox;
begin
  b := TBox.Create;
  b.FA := 1;
  b.FB := 2;
  SwapValues(b.A, b.B);
  if b.FA <> 2 then halt(1);
  if b.FB <> 1 then halt(2);
  if b.GetCalls <> 1 then halt(3);
  if b.SetCalls <> 1 then halt(4);
  b.Free;
end.
