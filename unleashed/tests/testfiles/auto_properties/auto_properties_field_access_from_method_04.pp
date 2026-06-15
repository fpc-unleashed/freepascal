program auto_properties_field_access_from_method_04;

{$mode unleashed}

// the synthesized backing field is a real strict-private member, reachable by
// name from any method of the type
type
  TAccount = class
    property Balance: Integer;
    procedure Deposit(amount: Integer);
    function Raw: Integer;
  end;

procedure TAccount.Deposit(amount: Integer);
begin
  FBalance := FBalance + amount;
end;

function TAccount.Raw: Integer;
begin
  Result := FBalance;
end;

var
  a: TAccount;
begin
  a := TAccount.Create;
  a.Balance := 100;
  a.Deposit(50);
  if a.Balance <> 150 then halt(1);
  if a.Raw <> 150 then halt(2);
  a.Free;
end.
