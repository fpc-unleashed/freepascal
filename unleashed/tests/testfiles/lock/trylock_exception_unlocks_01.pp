program trylock_exception_unlocks_01;
{$mode unleashed}

uses SysUtils;

var
  counter: Integer;
  caught: Boolean;

begin
  counter := 0;
  caught := false;
  try
    trylock(counter) wait 1000 do
    begin
      Inc(counter);
      raise Exception.Create('boom');
    end
    else halt(1);
  except
    on E: Exception do caught := true;
  end;
  if not caught then halt(2);
  if counter <> 1 then halt(3);
  // the finally released the CS - an immediate retry must succeed
  trylock(counter) do Inc(counter) else halt(4);
  if counter <> 2 then halt(5);
end.
