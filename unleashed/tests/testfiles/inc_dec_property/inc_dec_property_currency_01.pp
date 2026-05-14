program inc_dec_property_currency_01;

{$mode unleashed}

type
  TWallet = class
  private
    FBalance: Currency;
    function GetBalance: Currency;
    procedure SetBalance(v: Currency);
  public
    property Balance: Currency read GetBalance write SetBalance;
  end;

function TWallet.GetBalance: Currency;
begin
  Result := FBalance;
end;

procedure TWallet.SetBalance(v: Currency);
begin
  FBalance := v;
end;

begin
  var w := autofree TWallet.Create;
  w.Balance := 100;
  Inc(w.Balance, 50);
  if w.Balance <> 150 then halt(1);
  Dec(w.Balance, 25);
  if w.Balance <> 125 then halt(2);
end.
