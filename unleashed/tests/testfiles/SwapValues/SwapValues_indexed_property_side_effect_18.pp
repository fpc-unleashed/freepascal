program SwapValues_indexed_property_side_effect_18;
{$mode unleashed}
// array property with a side-effecting index expression: the index runs
// once and the same element is read and written
type
  TBox = class
  public
    FBuf: array[4] of Integer;
    GetCalls, SetCalls: Integer;
    function GetSlot(i: Integer): Integer;
    procedure SetSlot(i, v: Integer);
    property Items[i: Integer]: Integer read GetSlot write SetSlot;
  end;

function TBox.GetSlot(i: Integer): Integer; begin Inc(GetCalls); Result := FBuf[i]; end;
procedure TBox.SetSlot(i, v: Integer); begin Inc(SetCalls); FBuf[i] := v; end;

var
  b: TBox;
  x: Integer;
  idxcalls: Integer;

function NextIdx: Integer;
begin
  Inc(idxcalls);
  Result := 2;
end;

begin
  b := TBox.Create;
  b.FBuf[2] := 10;
  x := 99;
  idxcalls := 0;
  SwapValues(b.Items[NextIdx], x);
  if idxcalls <> 1 then halt(1);
  if b.FBuf[2] <> 99 then halt(2);
  if x <> 10 then halt(3);
  if b.GetCalls <> 1 then halt(4);
  if b.SetCalls <> 1 then halt(5);
  b.Free;
end.
