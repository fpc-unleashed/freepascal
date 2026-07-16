program lock_multi_field_and_global_01;
{$mode unleashed}

// multi-target list mixing an instance field CS with a global CS
var
  globalcs: TRTLCriticalSection;
  gcount: Integer;

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
  lock(cs, globalcs) do
    begin
      Inc(n);
      Inc(gcount);
    end;
end;

var
  a: TFoo;
begin
  InitCriticalSection(globalcs);
  gcount := 0;
  a := TFoo.Create;
  a.Bump;
  a.Bump;
  if a.n <> 2 then halt(1);
  if gcount <> 2 then halt(2);
  a.Free;
  DoneCriticalSection(globalcs);
end.
