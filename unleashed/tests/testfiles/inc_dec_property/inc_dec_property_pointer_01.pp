program inc_dec_property_pointer_01;

{$mode unleashed}

type
  TBag = class
  private
    FP: PByte;
    function GetP: PByte;
    procedure SetP(v: PByte);
  public
    property P: PByte read GetP write SetP;
  end;

function TBag.GetP: PByte;
begin
  Result := FP;
end;

procedure TBag.SetP(v: PByte);
begin
  FP := v;
end;

var
  buf: array[0..9] of Byte;

begin
  var b := autofree TBag.Create;
  b.P := @buf[0];
  Inc(b.P);
  if b.P <> @buf[1] then halt(1);
  Inc(b.P, 3);
  if b.P <> @buf[4] then halt(2);
  Dec(b.P, 2);
  if b.P <> @buf[2] then halt(3);
end.
