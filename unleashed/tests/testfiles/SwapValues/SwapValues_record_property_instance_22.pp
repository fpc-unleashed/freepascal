program SwapValues_record_property_instance_22;
{$mode unleashed}
// record instance behind a side-effecting index: the instance is captured
// by address, so the setter reaches the original array element
type
  TPt = record
  private
    FX: Integer;
    function GetX: Integer;
    procedure SetX(v: Integer);
  public
    property X: Integer read GetX write SetX;
  end;

function TPt.GetX: Integer; begin Result := FX; end;
procedure TPt.SetX(v: Integer); begin FX := v; end;

var
  arr: array[4] of TPt;
  idxcalls: Integer;
  v: Integer;

function NextIdx: Integer;
begin
  Inc(idxcalls);
  Result := 1;
end;

begin
  arr[1].FX := 10;
  v := 20;
  idxcalls := 0;
  SwapValues(arr[NextIdx].X, v);
  if idxcalls <> 1 then halt(1);
  if arr[1].FX <> 20 then halt(2);
  if v <> 10 then halt(3);
end.
