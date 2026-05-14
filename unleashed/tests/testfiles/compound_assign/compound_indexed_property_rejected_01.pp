{ %FAIL }
program compound_indexed_property_rejected_01;

{$mode unleashed}

type
  TBag = class
  private
    FArr: array[0..3] of Integer;
    function GetItem(i: Integer): Integer;
    procedure SetItem(i, v: Integer);
  public
    property Item[i: Integer]: Integer read GetItem write SetItem; default;
  end;

function TBag.GetItem(i: Integer): Integer;
begin
  Result := FArr[i];
end;

procedure TBag.SetItem(i, v: Integer);
begin
  FArr[i] := v;
end;

begin
  var b := autofree TBag.Create;
  b[0] := 10;
  // compound assign on indexed property is rejected
  b[0] += 5;
end.
