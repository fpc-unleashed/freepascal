program try_with_for_counter_after_exception_01;

{$mode unleashed}

uses SysUtils;

var
  i: Integer;

begin
  i := -1;
  try
    for i := 1 to 100 do
      if i = 13 then
        raise Exception.Create('stop');
  except
    on E: Exception do
      ;
  end;
  // unleashed mode keeps the counter value at the time of raise
  if i <> 13 then halt(1);
end.
