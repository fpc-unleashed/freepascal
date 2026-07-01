program trylock_uncontended_01;
{$mode unleashed}

var
  counter: Integer;
  cs: TRTLCriticalSection;

begin
  counter := 0;
  // free lock: fast path acquires without waiting
  trylock(counter) wait 100 do Inc(counter) else halt(1);
  if counter <> 1 then halt(2);
  // bare callsite form, block body
  trylock wait 50 do
  begin
    Inc(counter);
    Inc(counter);
  end
  else halt(3);
  if counter <> 3 then halt(4);
  // runtime wait expression
  trylock(counter) wait counter * 10 do Inc(counter) else halt(5);
  if counter <> 4 then halt(6);
  // explicit CS
  InitCriticalSection(cs);
  try
    trylock(cs) wait 100 do Inc(counter) else halt(7);
  finally
    DoneCriticalSection(cs);
  end;
  if counter <> 5 then halt(8);
  // empty else is the explicit "skip if busy" spelling
  trylock(counter) do Inc(counter) else ;
  if counter <> 6 then halt(9);
end.
