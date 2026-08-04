unit uinline_forced_crossunit_var_param_01;

{$mode unleashed}

interface

procedure bump(var value: byte; const delta: longint); inline;

implementation

procedure bump(var value: byte; const delta: longint);
begin
  inc(value, delta);
end;

end.
