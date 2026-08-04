{ inc/dec on a class property: rewrite to setter(getter +/- delta)
  for non-indexed read+write property with procsym getter }
program inc_dec_property_accessor_calls_01;

{$mode unleashed}

type
  TBox = class
  private
    FN: integer;
    FB: byte;
    GetCalls, SetCalls: integer;
    function GetN: integer;
    procedure SetN(v: integer);
    function GetB: byte;
    procedure SetB(v: byte);
  public
    property N: integer read GetN write SetN;
    property B: byte read GetB write SetB;
  end;

function TBox.GetN: integer;     begin Inc(GetCalls); Result := FN; end;
procedure TBox.SetN(v: integer); begin Inc(SetCalls); FN := v; end;
function TBox.GetB: byte;        begin Result := FB; end;
procedure TBox.SetB(v: byte);    begin FB := v; end;

var
  b: TBox;

begin
  b := TBox.Create;
  b.N := 10;

  b.GetCalls := 0;
  b.SetCalls := 0;
  inc(b.N);
  if b.N <> 11 then Halt(1);
  if b.GetCalls <> 2 then Halt(2);
  if b.SetCalls <> 1 then Halt(3);

  b.GetCalls := 0;
  b.SetCalls := 0;
  inc(b.N, 5);
  if b.N <> 16 then Halt(4);
  if b.GetCalls <> 2 then Halt(5);
  if b.SetCalls <> 1 then Halt(6);

  dec(b.N);
  if b.N <> 15 then Halt(7);
  dec(b.N, 10);
  if b.N <> 5 then Halt(8);

  b.B := 250;
  inc(b.B, 3);
  if b.B <> 253 then Halt(9);
  dec(b.B, 100);
  if b.B <> 153 then Halt(10);

  b.Free;
end.
