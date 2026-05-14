program defer_accessing_modified_var_01;

{$mode unleashed}

uses SysUtils;

var
  trace: String = '';

procedure DoWork;
var
  state: String;
begin
  state := 'start';
  defer trace := trace + 'final=' + state + ';';
  state := 'middle';
  state := 'end';
end;

begin
  DoWork;
  // defer body evaluates at exit time, sees the latest state
  if trace <> 'final=end;' then halt(1);
end.
