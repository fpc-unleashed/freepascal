{ %FAIL }
{ compound assignment and inc/dec on indexed/parametrized properties must
  report type_e_property_modify_indexed }
program compound_indexed_property_rejected_02;

{$mode unleashed}

type
  TFoo = class
  private
    FBuf: array[0..3] of integer;
    function GetSlot(i: integer): integer;
    procedure SetSlot(i: integer; v: integer);
  public
    property Items[i: integer]: integer read GetSlot write SetSlot;
  end;

function TFoo.GetSlot(i: integer): integer;
begin
  Result := FBuf[i];
end;

procedure TFoo.SetSlot(i: integer; v: integer);
begin
  FBuf[i] := v;
end;

var f: TFoo;
begin
  f := TFoo.Create;
  f.Items[0] += 1;
  f.Free;
end.
