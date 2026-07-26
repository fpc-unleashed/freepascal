{ %FAIL %OPT=-Seh }
program SwapValues_fail_property_hint_after_pop_25;
{$mode unleashed}
// the hint is silent inside the pushed region and comes back after the
// pop; with -Seh the second swap must fail the build
type
  TBox = class
  public
    FA, FB: Integer;
    function GetA: Integer;
    procedure SetA(v: Integer);
    property A: Integer read GetA write SetA;
  end;

function TBox.GetA: Integer; begin Result := FA; end;
procedure TBox.SetA(v: Integer); begin FA := v; end;

var
  b: TBox;
begin
  b := TBox.Create;
  {$push}{$WARN 4141 OFF}
  SwapValues(b.A, b.FB);
  {$pop}
  SwapValues(b.A, b.FB);
  b.Free;
end.
