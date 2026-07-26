{ %FAIL %OPT=-Seh }
program SwapValues_fail_property_hint_23;
{$mode unleashed}
// the not-in-place hint fires for a property operand; -Seh turns it into
// an error, so this must not compile
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
  x := 1;
  SwapValues(b.A, x);
  b.Free;
end.
