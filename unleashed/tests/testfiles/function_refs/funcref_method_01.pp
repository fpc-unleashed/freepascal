program funcref_method_01;

{$mode unleashed}

type
  TGetter = reference to function: Integer;

  TBox = class
  private
    FN: Integer;
  public
    constructor Create(N: Integer);
    function GetN: Integer;
  end;

constructor TBox.Create(N: Integer);
begin
  FN := N;
end;

function TBox.GetN: Integer;
begin
  Result := FN;
end;

begin
  var b := autofree TBox.Create(42);
  var g: TGetter := @b.GetN;
  if g <> nil then
    if g() <> 42 then halt(1);
end.
