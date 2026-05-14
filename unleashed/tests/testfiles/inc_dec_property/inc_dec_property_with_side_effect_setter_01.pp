program inc_dec_property_with_side_effect_setter_01;

{$mode unleashed}

var
  setter_calls: Integer = 0;

type
  TBox = class
  private
    FN: Integer;
    function GetN: Integer;
    procedure SetN(v: Integer);
  public
    property N: Integer read GetN write SetN;
  end;

function TBox.GetN: Integer;
begin
  Result := FN;
end;

procedure TBox.SetN(v: Integer);
begin
  FN := v;
  Inc(setter_calls);
end;

begin
  var b := autofree TBox.Create;
  b.N := 0;     // setter call 1
  if setter_calls <> 1 then halt(1);

  Inc(b.N);     // setter call 2 (rewrite: b.N := b.N + 1)
  if setter_calls <> 2 then halt(2);
  if b.N <> 1   then halt(3);

  Inc(b.N, 10); // setter call 3
  if setter_calls <> 3 then halt(4);
  if b.N <> 11  then halt(5);
end.
