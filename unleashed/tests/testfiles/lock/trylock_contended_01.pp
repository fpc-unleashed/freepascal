program trylock_contended_01;
{$mode unleashed}

uses SysUtils;

var
  shared: Integer;
  holding, release: Boolean;

function Worker(p: Pointer): PtrInt;
begin
  Result := 0;
  lock(shared) do
  begin
    holding := true;
    while not release do
      Sleep(10);
  end;
end;

var
  tid: TThreadID;
  h: TThreadID;
  t0, elapsed: QWord;
begin
  shared := 0;
  holding := false;
  release := false;
  h := BeginThread(@Worker, nil, tid);
  while not holding do
    Sleep(5);
  // busy lock: must take the else branch after roughly the budget
  t0 := GetTickCount64;
  trylock(shared) wait 150 do
    halt(1)
  else
    Inc(shared);
  elapsed := GetTickCount64 - t0;
  if shared <> 1 then halt(2);
  if elapsed < 100 then halt(3);
  if elapsed > 5000 then halt(4);
  // busy lock without a budget: instant else
  t0 := GetTickCount64;
  trylock(shared) do
    halt(5)
  else
    Inc(shared);
  if GetTickCount64 - t0 > 100 then halt(6);
  if shared <> 2 then halt(7);
  // worker releases - a generous budget must now succeed
  release := true;
  trylock(shared) wait 10000 do
    Inc(shared)
  else
    halt(8);
  if shared <> 3 then halt(9);
  WaitForThreadTerminate(h, 10000);
end.
