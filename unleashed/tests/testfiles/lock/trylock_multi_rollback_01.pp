program trylock_multi_rollback_01;
{$mode unleashed}

uses SysUtils;

// sorted lock order is a, b - the worker holds only b, so the timed
// multi-lock takes a, fails on b and must ROLL a BACK before the else
var
  a, b: Integer;
  holding, release: Boolean;

function Worker(p: Pointer): PtrInt;
begin
  Result := 0;
  lock(b) do
  begin
    holding := true;
    while not release do
      Sleep(10);
  end;
end;

var
  tid: TThreadID;
  h: TThreadID;
begin
  a := 0; b := 0;
  holding := false; release := false;
  h := BeginThread(@Worker, nil, tid);
  while not holding do
    Sleep(5);
  trylock(a, b) wait 100 do
    halt(1)
  else
    Inc(a);
  if a <> 1 then halt(2);
  // rollback proof: `a` must be free for an immediate single try
  trylock(a) do
    Inc(a)
  else
    halt(3);
  if a <> 2 then halt(4);
  release := true;
  WaitForThreadTerminate(h, 10000);
  // both free again
  trylock(a, b) do
  begin
    Inc(a); Inc(b);
  end
  else halt(5);
  if (a <> 3) or (b <> 1) then halt(6);
end.
