{ %OPT="-O3 -Sen" }
program autoinline_seh_finally_quiet_01;

{$mode unleashed}

// On win64 SEH a try..finally outlines the finally block into a hidden
// $fin$ exceptfilter routine flagged as containing assembler. The
// auto-inliner used to pick that funclet as a candidate and reject it
// with a user-visible note pointing at the last statement of the finally
// block. -Sen promotes notes to errors, so this test fails to compile if
// either the funclet is considered again or the speculative rejection
// becomes noisy again.

var
  traced: longint = 0;

procedure work;
var
  o: TObject;
begin
  o := TObject.Create;
  try
    if o.ClassName <> '' then
      inc(traced);
  finally
    o.Free;
  end;
end;

begin
  work;
  if traced <> 1 then
    halt(1);
  writeln('ok');
end.
