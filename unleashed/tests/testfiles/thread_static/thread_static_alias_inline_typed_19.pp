program thread_static_alias_inline_typed_19;
{$mode unleashed}
uses classes;

// inline typed form for both keywords; zero-initialised once per thread and
// persists across calls within the same thread. Different call counts per
// worker catch any shared (non per-thread) storage.

type
  TWorker = class(TThread)
  protected
    fcalls: Integer;
    fc, fd: Integer;
    procedure Step;
    procedure Execute; override;
  end;

procedure TWorker.Step;
begin
  threadstatic c: Integer;
  tstatic d: Integer;
  Inc(c);
  Inc(d, 10);
  fc := c;
  fd := d;
end;

procedure TWorker.Execute;
var
  i: Integer;
begin
  for i := 1 to fcalls do Step;
end;

var
  w1, w2: TWorker;
begin
  w1 := TWorker.Create(true); w1.fcalls := 4;
  w2 := TWorker.Create(true); w2.fcalls := 2;
  w1.Start; w2.Start;
  w1.WaitFor; w2.WaitFor;
  if w1.fc <> 4 then halt(1);    // 0 -> 4 over 4 calls
  if w1.fd <> 40 then halt(2);   // 0 -> 40
  if w2.fc <> 2 then halt(3);
  if w2.fd <> 20 then halt(4);
  w1.Free; w2.Free;
end.
