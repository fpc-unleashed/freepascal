program thread_static_per_thread_02;
{$mode unleashed}
uses classes, sysutils, syncobjs;

// two threads each run the same routine, each gets its own counter
// from its own threadstatic; the final values are checked back on
// the main thread via thread-result fields

type
  TWorker = class(TThread)
  protected
    fid: Integer;
    fresult: Integer;
    procedure Execute; override;
  end;

procedure TWorker.Execute;
var i: Integer;
begin
  threadstatic cnt := 0;
  for i := 1 to 5 do
    Inc(cnt);
  fresult := cnt;
end;

var
  w1, w2: TWorker;
begin
  w1 := TWorker.Create(true); w1.fid := 1;
  w2 := TWorker.Create(true); w2.fid := 2;
  w1.Start;
  w2.Start;
  w1.WaitFor;
  w2.WaitFor;
  if w1.fresult <> 5 then halt(1);
  if w2.fresult <> 5 then halt(2);
  w1.Free;
  w2.Free;
end.
