program defer_evaluates_at_exit_01;

{$mode unleashed}

uses SysUtils;

var
  trace: String = '';
  n: Integer;

procedure DoWork;
begin
  n := 1;
  // unlike Go: the argument is evaluated at exit, not at registration
  defer trace := trace + IntToStr(n);
  n := 999;
end;

begin
  DoWork;
  // n was 999 when defer fired
  if trace <> '999' then halt(1);
end.
