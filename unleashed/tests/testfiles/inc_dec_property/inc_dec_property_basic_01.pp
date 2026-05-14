program inc_dec_property_basic_01;

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
  c.N := 10;
  Inc(c.N);
  if c.N <> 11 then halt(1);
  Inc(c.N, 5);
  if c.N <> 16 then halt(2);
  Dec(c.N);
  if c.N <> 15 then halt(3);
  Dec(c.N, 5);
  if c.N <> 10 then halt(4);
end.
