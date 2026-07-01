program lock_exception_unlocks_01;
{$mode unleashed}

uses SysUtils;

var
  counter: Integer;
  caught: Boolean;

begin
  counter := 0;
  caught := false;
  try
    lock(counter) do begin
      Inc(counter);
      raise Exception.Create('boom');
    end;
  except
    on E: Exception do
      caught := true;
  end;
  if not caught then halt(1);
  if counter <> 1 then halt(2);
  // second lock would deadlock if the first did not unlock
  lock(counter) do Inc(counter);
  if counter <> 2 then halt(3);
end.
