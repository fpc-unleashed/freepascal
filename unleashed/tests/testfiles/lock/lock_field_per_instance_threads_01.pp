program lock_field_per_instance_threads_01;
{$mode unleashed}

// a field CS serializes per instance: two instances, two threads each,
// every increment must survive
uses
  SysUtils, Classes;

const
  loops = 50000;

type
  TCounter = class
    cs: TRTLCriticalSection;
    n: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Bump;
  end;

  TWorker = class(TThread)
    target: TCounter;
    constructor Create(atarget: TCounter);
    procedure Execute; override;
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
var
  i: Integer;
begin
  for i := 1 to loops do
    lock(cs) do n := n + 1;
end;

constructor TWorker.Create(atarget: TCounter);
begin
  target := atarget;
  inherited Create(false);
end;

procedure TWorker.Execute;
begin
  target.Bump;
end;

var
  a, b: TCounter;
  t: array[4] of TWorker;
  i: Integer;
begin
  a := TCounter.Create;
  b := TCounter.Create;
  t[0] := TWorker.Create(a);
  t[1] := TWorker.Create(a);
  t[2] := TWorker.Create(b);
  t[3] := TWorker.Create(b);
  for i := 0 to 3 do
    begin
      t[i].WaitFor;
      t[i].Free;
    end;
  if a.n <> 2 * loops then halt(1);
  if b.n <> 2 * loops then halt(2);
  a.Free;
  b.Free;
end.
