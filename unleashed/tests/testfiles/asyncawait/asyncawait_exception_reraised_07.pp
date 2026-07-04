{ an exception raised on the worker is re-raised at `await` }
program asyncawait_exception_reraised_07;
{$mode unleashed}
uses SysUtils;
function boom: Integer;
begin
  raise Exception.Create('boom');
end;
var caught: Boolean;
begin
  caught := false;
  var bad := async boom;
  try
    if await bad = 0 then halt(1);
  except
    on E: Exception do
      caught := E.Message = 'boom';
  end;
  if not caught then halt(2);
end.
