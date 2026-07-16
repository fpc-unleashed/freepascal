program trylock_field_01;
{$mode unleashed}

// trylock accepts an explicit CS instance field
type
  TFoo = class
    cs: TRTLCriticalSection;
    n: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Bump;
  end;

constructor TFoo.Create;
begin
  InitCriticalSection(cs);
end;

destructor TFoo.Destroy;
begin
  DoneCriticalSection(cs);
  inherited;
end;

procedure TFoo.Bump;
begin
  trylock(cs) do Inc(n) else halt(1);
end;

var
  a: TFoo;
begin
  a := TFoo.Create;
  a.Bump;
  a.Bump;
  if a.n <> 2 then halt(2);
  a.Free;
end.
