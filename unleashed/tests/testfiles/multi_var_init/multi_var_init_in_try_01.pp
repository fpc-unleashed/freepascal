program multi_var_init_in_try_01;

{$mode unleashed}

uses SysUtils;

begin
  var ok := true;
  try
    var a, b, c: Integer := 7;
    if (a <> 7) or (b <> 7) or (c <> 7) then ok := false;
    raise Exception.Create('after-init');
  except
    on E: Exception do ;
  end;
  if not ok then halt(1);
end.
