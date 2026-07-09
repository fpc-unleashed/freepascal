program anon_capture_mainbody_inline_var_01;

{$mode unleashed}

// closure capturing an inline var declared in a main-program loop body
// crashed the compiler (IE 2020050302); main-body block vars are static,
// so the capture is a direct reference like for classic program vars
type
  TProc = reference to procedure;
  TBox = class
    v: integer;
  end;
var
  procs: array of TProc;
  total: integer;

procedure run(p: TProc);
begin
  p();
end;

begin
  total := 0;
  for var i := 1 to 3 do
  begin
    var s := i * 10;
    procs := procs + [procedure begin total := total + s end];
  end;
  for var k := 0 to High(procs) do
    run(procs[k]);
  // capture is by reference: every closure sees the last value (30),
  // same as classic vars and upstream anonymous functions
  if total <> 90 then halt(1);

  // sibling scopes with the same names must not collide
  procs := nil;
  begin
    var n := 1;
    procs := procs + [procedure begin total := n end];
  end;
  begin
    var n := 2;
    procs := procs + [procedure begin total := total + n end];
  end;
  procs[0]();
  procs[1]();
  if total <> 3 then halt(2);

  // with var holder in the main body is capturable too
  with var w := TBox.Create do
  begin
    w.v := 5;
    procs := procs + [procedure begin total := w.v end];
    procs[2]();
    w.Free;
  end;
  if total <> 5 then halt(3);
end.
