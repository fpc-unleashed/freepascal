program defer_break_continue_01;

{$mode unleashed}

uses SysUtils;

var
  trace: String = '';

begin
  for var i := 1 to 5 do
  begin
    defer trace := trace + 'D' + IntToStr(i) + ';';
    if i = 3 then break;
    if i mod 2 = 0 then continue;
    trace := trace + 'B' + IntToStr(i) + ';';
  end;
  // expected per iteration: i=1 body+defer; i=2 (continue) defer; i=3 (break) defer
  if trace <> 'B1;D1;D2;D3;' then halt(1);
end.
