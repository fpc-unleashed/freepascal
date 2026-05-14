program for_counter_after_inner_try_01;

{$mode unleashed}

uses SysUtils;

var
  i: Integer;

begin
  for i := 1 to 5 do
  begin
    try
      if i = 3 then
        raise Exception.Create('mid');
    except
      on E: Exception do ;
    end;
  end;
  // loop completes naturally; counter holds 5
  if i <> 5 then halt(1);
end.
