program defer_per_iteration_01;

{$mode unleashed}

uses SysUtils;

var
  trace: String = '';

begin
  for var i := 1 to 3 do
  begin
    defer trace := trace + 'D' + IntToStr(i) + ';';
    trace := trace + 'B' + IntToStr(i) + ';';
  end;
  // each iteration registers its own defer, fires at end of iteration block
  if trace <> 'B1;D1;B2;D2;B3;D3;' then halt(1);
end.
