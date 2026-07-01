program lock_explicit_cs_global_01;
{$mode unleashed}

var
  counter: Integer;
  cs: TRTLCriticalSection;

begin
  InitCriticalSection(cs);
  try
    counter := 0;
    lock(cs) do Inc(counter);
    lock(cs) do begin
      Inc(counter);
      Inc(counter);
    end;
    if counter <> 3 then halt(1);
  finally
    DoneCriticalSection(cs);
  end;
end.
