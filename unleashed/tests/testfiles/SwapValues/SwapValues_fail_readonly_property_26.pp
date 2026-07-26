{ %FAIL }
program SwapValues_fail_readonly_property_26;
{$mode unleashed}
// a read-only property has no write accessor to swap through
type
  TBox = class
  public
    FA: Integer;
    function GetA: Integer;
    property A: Integer read GetA;
  end;

function TBox.GetA: Integer; begin Result := FA; end;

var
  b: TBox;
  x: Integer;
begin
  b := TBox.Create;
  x := 1;
  SwapValues(b.A, x);
  b.Free;
end.
