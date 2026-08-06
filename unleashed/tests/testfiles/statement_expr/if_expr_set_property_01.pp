program if_expr_set_property_01;

{$mode unleashed}

type
  TShade = (shLow, shMid, shHigh);
  TShades = set of TShade;

  TWidget = class
  private
    fshades: TShades;
    procedure setshades(value: TShades);
  public
    property Shades: TShades read fshades write setshades;
  end;

procedure TWidget.setshades(value: TShades);
begin
  fshades := value;
end;

var
  w: TWidget;
  checked: boolean;
begin
  // assignment to a property of a set type
  w := TWidget.Create;
  checked := true;
  w.Shades := if checked then [shHigh] else [];
  if w.Shades <> [shHigh] then halt(1);
  checked := false;
  w.Shades := if checked then [shHigh] else [];
  if w.Shades <> [] then halt(2);
  w.Free;
end.
