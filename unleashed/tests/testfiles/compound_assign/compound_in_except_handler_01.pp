program compound_in_except_handler_01;

{$mode unleashed}

uses SysUtils;

var
  errors: Integer = 0;

begin
  for var i := 1 to 5 do
  begin
    try
      if i mod 2 = 0 then
        raise Exception.Create('even');
    except
      on E: Exception do
        errors += 1;
    end;
  end;
  if errors <> 2 then halt(1);
end.
