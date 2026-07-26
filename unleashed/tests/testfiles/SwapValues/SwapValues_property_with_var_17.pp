program SwapValues_property_with_var_17;
{$mode unleashed}
// accessor property with a plain variable
type
  TBox = class
  public
    FA: Integer;
    function GetA: Integer;
    procedure SetA(v: Integer);
    property A: Integer read GetA write SetA;
  end;

function TBox.GetA: Integer; begin Result := FA; end;
procedure TBox.SetA(v: Integer); begin FA := v; end;

var
  b: TBox;
  x: Integer;
begin
  b := TBox.Create;
  b.FA := 10;
  x := 20;
  SwapValues(b.A, x);
  if b.FA <> 20 then halt(1);
  if x <> 10 then halt(2);
  // and the other way around
  SwapValues(x, b.A);
  if b.FA <> 10 then halt(3);
  if x <> 20 then halt(4);
  b.Free;
end.
