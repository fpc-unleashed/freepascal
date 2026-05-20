program composable_records_aligned_heap_getmem_01;

{$mode unleashed}

type
  TCacheLine = record
    v: int64 align 64;
  end;
  PCacheLine = ^TCacheLine;

var
  p: PCacheLine;
  i, bad: Integer;
  ps: array[0..9] of PCacheLine;
begin
  p := GetMemAligned(SizeOf(TCacheLine), 64);
  if p = nil then halt(1);
  if PtrUInt(@p^.v) mod 64 <> 0 then halt(2);
  FreeMemAligned(p);

  { stress test: 10 allocs all must land on 64-byte boundary }
  bad := 0;
  for i := 0 to 9 do
    begin
      ps[i] := GetMemAligned(SizeOf(TCacheLine), 64);
      if PtrUInt(@ps[i]^.v) mod 64 <> 0 then Inc(bad);
    end;
  for i := 0 to 9 do FreeMemAligned(ps[i]);
  if bad <> 0 then halt(3);
end.
