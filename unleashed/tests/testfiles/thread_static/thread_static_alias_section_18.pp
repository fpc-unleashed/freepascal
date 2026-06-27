program thread_static_alias_section_18;
{$mode unleashed}
uses classes;

// section form: one routine uses the `threadstatic` spelling, another uses the
// `tstatic` alias. Each worker calls both twice, so the values prove init runs
// once per thread (not once per call) and storage is per-thread.

function StepA(n: Integer): Integer;
threadstatic
  a: Integer = 10;
begin
  Inc(a, n);
  Result := a;
end;

function StepB(n: Integer): Integer;
tstatic
  b: Integer = 20;
begin
  Inc(b, n);
  Result := b;
end;

type
  TWorker = class(TThread)
  protected
    fstep: Integer;
    fa, fb: Integer;
    procedure Execute; override;
  end;

procedure TWorker.Execute;
begin
  StepA(fstep);
  fa := StepA(fstep);   // a: 10 + fstep + fstep (init once)
  StepB(fstep);
  fb := StepB(fstep);   // b: 20 + fstep + fstep
end;

var
  w1, w2: TWorker;
begin
  w1 := TWorker.Create(true); w1.fstep := 3;
  w2 := TWorker.Create(true); w2.fstep := 5;
  w1.Start; w2.Start;
  w1.WaitFor; w2.WaitFor;
  if w1.fa <> 16 then halt(1);   // 10 + 3 + 3
  if w1.fb <> 26 then halt(2);   // 20 + 3 + 3
  if w2.fa <> 20 then halt(3);   // 10 + 5 + 5
  if w2.fb <> 30 then halt(4);   // 20 + 5 + 5
  w1.Free; w2.Free;
end.
