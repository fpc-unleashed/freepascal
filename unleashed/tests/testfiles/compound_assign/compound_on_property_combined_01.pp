{ compound assignment on a class property: getter+setter rewrite,
  bitwise/word-based ops, fieldvarsym short-circuit }
program compound_on_property_combined_01;

{$mode unleashed}
{$coperators on}

type
  TFoo = class
  private
    FName: string;
    FCounter: integer;
    FFlags: longword;
    GetCalls, SetCalls: integer;
    function GetName: string;
    procedure SetName(const v: string);
  public
    property Name: string read GetName write SetName;
    property Counter: integer read FCounter write FCounter;
    property Flags: longword read FFlags write FFlags;
  end;

function TFoo.GetName: string;
begin
  Inc(GetCalls);
  Result := FName;
end;

procedure TFoo.SetName(const v: string);
begin
  Inc(SetCalls);
  FName := v;
end;

var
  f: TFoo;

begin
  f := TFoo.Create;

  { procsym property: getter+setter accessors, one of each per += }
  f.Name := 'a';
  f.GetCalls := 0;
  f.SetCalls := 0;
  f.Name += 'b';
  if f.Name <> 'ab' then Halt(1);
  if f.GetCalls <> 2 then Halt(2);
  if f.SetCalls <> 1 then Halt(3);

  { fieldvarsym property: directly to backing field }
  f.Counter := 10;
  f.Counter += 5;
  if f.Counter <> 15 then Halt(4);
  f.Counter -= 3;
  if f.Counter <> 12 then Halt(5);
  f.Counter *= 2;
  if f.Counter <> 24 then Halt(6);
  f.Counter div= 4;
  if f.Counter <> 6 then Halt(7);
  f.Counter mod= 4;
  if f.Counter <> 2 then Halt(8);

  { bitwise compound on property }
  f.Flags := $FF;
  f.Flags and= $0F;
  if f.Flags <> $0F then Halt(9);
  f.Flags or= $30;
  if f.Flags <> $3F then Halt(10);
  f.Flags xor= $05;
  if f.Flags <> $3A then Halt(11);
  f.Flags shl= 4;
  if f.Flags <> $3A0 then Halt(12);
  f.Flags shr= 2;
  if f.Flags <> $E8 then Halt(13);

  f.Free;
end.
