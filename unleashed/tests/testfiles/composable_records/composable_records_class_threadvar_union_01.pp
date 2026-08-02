program composable_records_class_threadvar_union_01;
{ class threadvar union: each thread gets its own overlay blob }

{$mode unleashed}

{$ifdef unix}uses cthreads;{$endif}

type
  TFoo = record
    class threadvar
      union raw : DWord; packed record lo, mid, hi : Byte; end; end;
  end;

function worker(arg: pointer): ptrint;
begin
  TFoo.raw := $99887766;
  result := 0;
  if TFoo.lo <> $66 then result := 1;
end;

var
  h : TThreadID;

begin
  TFoo.raw := $11223344;
  h := BeginThread(@worker);
  if WaitForThreadTerminate(h, 30000) <> 0 then halt(1);
  { worker writes must not leak into the main thread copy }
  if TFoo.raw <> $11223344 then halt(2);
  if TFoo.mid <> $33 then halt(3);
end.
