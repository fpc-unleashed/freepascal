{ %CPU=x86_64,aarch64 }
program parallelfor_generic_34;
{$mode unleashed}
uses SysUtils;
// the generic body replays on each specialization: every copy builds its
// own worker proc and the dispatch width follows the specialized counter
type
  TSummer<T> = class
    FCount: Integer;
    procedure Run(lo, hi: T);
  end;

procedure TSummer<T>.Run(lo, hi: T);
begin
  for parallel var i := lo to hi do
    InterlockedIncrement(FCount);
end;

var
  s32: TSummer<Integer>;
  s64: TSummer<Int64>;
begin
  s32 := TSummer<Integer>.Create;
  s32.Run(1, 3000);
  if s32.FCount <> 3000 then halt(1);
  s32.Free;
  // past the 32-bit range: the specialized copy dispatches in 64 bits
  s64 := TSummer<Int64>.Create;
  s64.Run(4000000000, 4000000999);
  if s64.FCount <> 1000 then halt(2);
  s64.Free;
end.
