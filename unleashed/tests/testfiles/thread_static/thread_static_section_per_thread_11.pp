program thread_static_section_per_thread_11;
{$mode unleashed}
uses classes, sysutils;

// the section form must give each thread its own copy, exactly like the
// inline form: two workers accumulate into their own per-thread `acc`.

type
  TWorker = class(TThread)
  protected
    fadd: Integer;
    fresult: Integer;
    procedure Execute; override;
  end;

procedure TWorker.Execute;
threadstatic
  acc: Integer = 100;
var
  i: Integer;
begin
  for i := 1 to 5 do
    Inc(acc, fadd);
  fresult := acc;
end;

var
  w1, w2: TWorker;
begin
  w1 := TWorker.Create(true); w1.fadd := 1;
  w2 := TWorker.Create(true); w2.fadd := 10;
  w1.Start; w2.Start;
  w1.WaitFor; w2.WaitFor;
  if w1.fresult <> 105 then halt(1);   // 100 + 5*1
  if w2.fresult <> 150 then halt(2);   // 100 + 5*10
  w1.Free; w2.Free;
end.
