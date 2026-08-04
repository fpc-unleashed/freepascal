{ %FAIL }
{ inc/dec on a non-ordinal property must report type_e_inc_dec_property_type }
program inc_dec_property_non_ordinal_rejected_01;

{$mode unleashed}

type
  TFoo = class
  private
    FName: string;
    function GetName: string;
    procedure SetName(const v: string);
  public
    property Name: string read GetName write SetName;
  end;

function TFoo.GetName: string;
begin
  Result := FName;
end;

procedure TFoo.SetName(const v: string);
begin
  FName := v;
end;

var f: TFoo;
begin
  f := TFoo.Create;
  inc(f.Name);
  f.Free;
end.
