program composable_records_aligned_heap_freemem_nil_01;

{$mode unleashed}

var
  p: Pointer;
begin
  { NIL-safe }
  p := nil;
  FreeMemAligned(p);

  { ReAllocMemAligned with p=nil acts like GetMemAligned }
  ReAllocMemAligned(p, 64, 32);
  if p = nil then halt(1);
  if PtrUInt(p) mod 32 <> 0 then halt(2);

  { ReAllocMemAligned with new_size=0 acts like FreeMemAligned }
  ReAllocMemAligned(p, 0, 32);
  if p <> nil then halt(3);
end.
