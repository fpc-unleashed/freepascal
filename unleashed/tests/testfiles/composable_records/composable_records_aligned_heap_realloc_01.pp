program composable_records_aligned_heap_realloc_01;

{$mode unleashed}

var
  p: Pointer;
  q: PByte;
  i: Integer;
begin
  p := GetMemAligned(32, 32);
  if p = nil then halt(1);
  if PtrUInt(p) mod 32 <> 0 then halt(2);
  { fill with a sentinel pattern }
  q := p;
  for i := 0 to 31 do q[i] := Byte(i + 1);

  { grow }
  ReAllocMemAligned(p, 128, 64);
  if p = nil then halt(3);
  if PtrUInt(p) mod 64 <> 0 then halt(4);
  q := p;
  { original 32 bytes must be preserved }
  for i := 0 to 31 do
    if q[i] <> Byte(i + 1) then halt(5);

  { shrink }
  ReAllocMemAligned(p, 16, 16);
  if p = nil then halt(6);
  if PtrUInt(p) mod 16 <> 0 then halt(7);
  q := p;
  for i := 0 to 15 do
    if q[i] <> Byte(i + 1) then halt(8);

  FreeMemAligned(p);
end.
