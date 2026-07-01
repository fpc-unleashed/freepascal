program trylock_wait_int64_01;
{$mode unleashed}

// the wait budget is a signed 64-bit millisecond count - values beyond
// High(LongInt) are legal (uncontended here, so it acquires instantly)
var
  counter: Integer;
  ms: Int64;

begin
  counter := 0;
  ms := 3000000000;
  trylock(counter) wait ms do Inc(counter) else halt(1);
  if counter <> 1 then halt(2);
  trylock(counter) wait 4000000000 do Inc(counter) else halt(3);
  if counter <> 2 then halt(4);
  // a negative runtime value behaves like 0 (attempts only)
  ms := -50;
  trylock(counter) wait ms do Inc(counter) else halt(5);
  if counter <> 3 then halt(6);
end.
