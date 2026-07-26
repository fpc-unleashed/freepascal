{ %FAIL }
program SwapValues_fail_writeonly_property_28;
{$mode unleashed}
// a write-only property cannot be read for the swap
type
  TBox = class
  public
    FA: Integer;
    procedure SetA(v: Integer);
    property A: Integer write SetA;
  end;

procedure TBox.SetA(v: Integer); begin FA := v; end;

var
  b: TBox;
  x: Integer;
begin
  b := TBox.Create;
  x := 1;
  SwapValues(b.A, x);
  b.Free;
end.
