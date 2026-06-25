{ %OPT=-gw3 }
program thread_static_debuginfo_17;
{$mode unleashed}
uses classes;

// with debug info the compiler emits a per-thread DWARF location for the
// threadstatic and its guard; this checks those symbol refs link and that
// codegen still gives each thread its own copy

type
  TWorker = class(TThread)
  protected
    fresult: Integer;
    procedure Execute; override;
  end;

procedure TWorker.Execute;
var i: Integer;
begin
  threadstatic cnt := 100;
  for i := 1 to 5 do
    Inc(cnt);
  fresult := cnt;
end;

var
  w1, w2: TWorker;
begin
  w1 := TWorker.Create(true);
  w2 := TWorker.Create(true);
  w1.Start;
  w2.Start;
  w1.WaitFor;
  w2.WaitFor;
  if w1.fresult <> 105 then halt(1);
  if w2.fresult <> 105 then halt(2);
  w1.Free;
  w2.Free;
end.
