{ %PRECOMPILE=uinline_forced_crossunit_var_param_01.pas }
program inline_forced_crossunit_var_param_01;

{$mode unleashed}

// passing an own var parameter on keeps the call node around; the pending
// scan must not ask a routine from another unit whether it is still forward

uses uinline_forced_crossunit_var_param_01;

procedure step(var value: byte; const delta: longint);
begin
  bump(value, delta);
end;

var
  b: byte;
begin
  b := 10;
  step(b, 3);
  if b <> 13 then
    halt(1);
end.
