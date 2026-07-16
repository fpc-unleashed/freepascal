program lock_explicit_cs_deref_01;
{$mode unleashed}

// a dereferenced pointer to an explicit CS is a valid lock target; the
// address is snapshotted before acquisition, so reassigning the pointer
// inside the body must not change which section gets released
var
  cs1, cs2: TRTLCriticalSection;
  p: ^TRTLCriticalSection;
  counter: Integer;
begin
  InitCriticalSection(cs1);
  InitCriticalSection(cs2);
  counter := 0;
  p := @cs1;
  lock(p^) do
    begin
      Inc(counter);
      p := @cs2;
    end;
  // cs1 must be free again - a second lock through a fresh pointer succeeds
  p := @cs1;
  lock(p^) do Inc(counter);
  if counter <> 2 then halt(1);
  DoneCriticalSection(cs1);
  DoneCriticalSection(cs2);
end.
