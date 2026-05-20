program composable_records_aligned_heap_allocmem_01;

{$mode unleashed}

var
  p: PByte;
  i: Integer;
begin
  p := AllocMemAligned(64, 32);
  if p = nil then halt(1);
  if PtrUInt(p) mod 32 <> 0 then halt(2);
  { AllocMemAligned must zero-fill the user portion }
  for i := 0 to 63 do
    if p[i] <> 0 then halt(3);
  FreeMemAligned(p);
end.
