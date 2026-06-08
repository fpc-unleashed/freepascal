unit lightgenerics_cross_module_3way_a;
{$mode unleashed}
{$modeswitch lightgenerics}

interface

type
  TBox<T>=class(TObject)
    FValue: T;
    procedure SetValue(const A: T);
    function GetValue: T;
  end;

implementation

procedure TBox<T>.SetValue(const A: T);
begin
  FValue := A;
end;

function TBox<T>.GetValue: T;
begin
  Result := FValue;
end;

end.
