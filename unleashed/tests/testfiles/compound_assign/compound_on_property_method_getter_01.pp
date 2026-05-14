program compound_on_property_method_getter_01;

{$mode unleashed}

type
  TCounter = class
  private
    FN: Integer;
    function GetN: Integer;
    procedure SetN(v: Integer);
  public
    property N: Integer read GetN write SetN;
  end;

function TCounter.GetN: Integer;
begin
  Result := FN;
end;

procedure TCounter.SetN(v: Integer);
begin
  FN := v;
end;

begin
  var c := autofree TCounter.Create;
  c.N := 5;
  c.N += 3;
  if c.N <> 8 then halt(1);
  c.N *= 2;
  if c.N <> 16 then halt(2);
end.
