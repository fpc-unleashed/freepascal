program lock_explicit_cs_local_01;
{$mode unleashed}

var
  counter: Integer;

procedure DoWork;
var
  localCS: TRTLCriticalSection;
begin
  InitCriticalSection(localCS);
  try
    lock(localCS) do Inc(counter);
    lock(localCS) do Inc(counter);
  finally
    DoneCriticalSection(localCS);
  end;
end;

begin
  counter := 0;
  DoWork;
  DoWork;
  if counter <> 4 then halt(1);
end.
