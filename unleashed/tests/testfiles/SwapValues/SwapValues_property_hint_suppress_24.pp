{ %OPT=-Seh }
program SwapValues_property_hint_suppress_24;
{$mode unleashed}
// -Seh turns the not-in-place hint into an error; all three suppression
// forms must silence it for this to compile
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
  b.FA := 1;
  b.FB := 2;

  {$WARN 4141 OFF}
  SwapValues(b.A, b.FB);
  {$WARN 4141 ON}

  {$push}{$HINTS OFF}
  SwapValues(b.A, b.FB);
  {$pop}

  {$push}{$WARN 4141 OFF}
  SwapValues(b.A, b.FB);
  {$pop}

  // three swaps: net effect is one swap
  if b.FA <> 2 then halt(1);
  if b.FB <> 1 then halt(2);
  b.Free;
end.
