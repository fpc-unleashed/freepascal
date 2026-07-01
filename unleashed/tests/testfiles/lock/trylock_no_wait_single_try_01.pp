program trylock_no_wait_single_try_01;
{$mode unleashed}

// no `wait` clause and `wait 0` are the same thing: attempts only
// (one TryEnter plus a few yields), no sleeping
var
  counter: Integer;

begin
  counter := 0;
  trylock(counter) do Inc(counter) else halt(1);
  if counter <> 1 then halt(2);
  trylock(counter) wait 0 do Inc(counter) else halt(3);
  if counter <> 2 then halt(4);
  // same thread re-entry: recursive CS, immediate try still succeeds
  trylock(counter) do
    trylock(counter) do
      Inc(counter)
    else halt(5)
  else halt(6);
  if counter <> 3 then halt(7);
end.
