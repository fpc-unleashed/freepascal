program SwapValues_property_getset_15;
{$mode unleashed}
// two accessor properties swap through a temporary: one getter and one
// setter call per operand, values exchanged
type
  TBox = class
  public
    FA, FB: Integer;
    GetACalls, SetACalls, GetBCalls, SetBCalls: Integer;
    function GetA: Integer;
    procedure SetA(v: Integer);
    function GetB: Integer;
    procedure SetB(v: Integer);
    property A: Integer read GetA write SetA;
    property B: Integer read GetB write SetB;
  end;

function TBox.GetA: Integer; begin Inc(GetACalls); Result := FA; end;
procedure TBox.SetA(v: Integer); begin Inc(SetACalls); FA := v; end;
function TBox.GetB: Integer; begin Inc(GetBCalls); Result := FB; end;
procedure TBox.SetB(v: Integer); begin Inc(SetBCalls); FB := v; end;

var
  b: TBox;
begin
  b := TBox.Create;
  b.FA := 1;
  b.FB := 2;
  SwapValues(b.A, b.B);
  if b.FA <> 2 then halt(1);
  if b.FB <> 1 then halt(2);
  if b.GetACalls <> 1 then halt(3);
  if b.SetACalls <> 1 then halt(4);
  if b.GetBCalls <> 1 then halt(5);
  if b.SetBCalls <> 1 then halt(6);
  b.Free;
end.
