program lock_explicit_cs_field_01;
{$mode unleashed}

// an explicit TRTLCriticalSection instance field is a valid lock target
type
  TCounter = class
    cs: TRTLCriticalSection;
    n: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Bump;
  end;

constructor TCounter.Create;
begin
  InitCriticalSection(cs);
end;

destructor TCounter.Destroy;
begin
  DoneCriticalSection(cs);
  inherited;
end;

procedure TCounter.Bump;
begin
  lock(cs) do Inc(n);
end;

var
  a, b: TCounter;
begin
  a := TCounter.Create;
  b := TCounter.Create;
  a.Bump;
  a.Bump;
  b.Bump;
  if a.n <> 2 then halt(1);
  if b.n <> 1 then halt(2);
  a.Free;
  b.Free;
end.
