program thread_static_alias_inline_inferred_20;
{$mode unleashed}
uses classes;

// inline inferred form for both keywords; the literal initialiser promotes to
// LongInt, so values well past the ShortInt range (here 200..400) hold. Also
// checks init-once and per-thread persistence.

type
  TWorker = class(TThread)
  protected
    fcalls: Integer;
    fe, ff: Int64;
    procedure Step;
    procedure Execute; override;
  end;

procedure TWorker.Step;
begin
  threadstatic e := 1000;
  tstatic f := 100;
  Inc(e);
  Inc(f, 100);
  fe := e;
  ff := f;
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
  w1 := TWorker.Create(true); w1.fcalls := 3;
  w2 := TWorker.Create(true); w2.fcalls := 1;
  w1.Start; w2.Start;
  w1.WaitFor; w2.WaitFor;
  if w1.fe <> 1003 then halt(1);
  if w1.ff <> 400 then halt(2);   // 100 + 3*100; past ShortInt -> inferred wider
  if w2.fe <> 1001 then halt(3);
  if w2.ff <> 200 then halt(4);
  w1.Free; w2.Free;
end.
