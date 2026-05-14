program try_with_inline_var_01;

{$mode unleashed}

uses SysUtils;

begin
  var caught := false;
  try
    var n := 10;
    if n > 5 then
      raise Exception.Create('over');
    halt(99);
  except
    on E: Exception do
      caught := true;
  end;
  if not caught then halt(1);
end.
