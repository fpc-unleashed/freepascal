program inline_var_used_in_except_handler_01;

{$mode unleashed}

uses SysUtils;

begin
  var marker := 'before';
  try
    raise Exception.Create('boom');
  except
    on E: Exception do
    begin
      // marker is in scope of the surrounding begin..end; reachable here
      if marker <> 'before' then halt(1);
      marker := 'after';
    end;
  end;
  if marker <> 'after' then halt(2);
end.
