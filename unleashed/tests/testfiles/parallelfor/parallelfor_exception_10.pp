program parallelfor_exception_10;
{$mode unleashed}
uses SysUtils;
// a fault on any worker is caught and re-raised once on the calling thread
procedure Work;
begin
  for parallel var i := 1 to 200 do
    if i = 42 then raise Exception.Create('boom');
end;
var got: Boolean;
begin
  got := False;
  try
    Work;
  except
    on e: Exception do got := e.Message = 'boom';
  end;
  if not got then halt(1);
end.
