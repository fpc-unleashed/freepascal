{ %FAIL }
program asyncawait_nested_target_fails_07;
{$mode unleashed}
uses SysUtils;
procedure outer;
var local: Integer;
  function inner: Integer;
  begin
    result := local * 2;
  end;
begin
  local := 21;
  var f := async inner;
  writeln(await f);
end;
begin
  outer;
end.
