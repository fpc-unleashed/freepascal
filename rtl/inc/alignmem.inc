{
    Heap allocation with explicit alignment.

    Default GetMem returns pointers aligned to MaxAllocAlignment (16 on
    x86_64). For cache-line padding (`field: T align 64`) on heap-allocated
    structures, GetMem is insufficient. GetMemAligned over-allocates to
    cover the requested alignment, stores the raw allocation pointer in
    the word immediately before the aligned address, and returns the
    aligned pointer. FreeMemAligned recovers the raw pointer from the
    header and forwards to FreeMem.

    `alignment` must be a power of two and at least sizeof(pointer).
    Invalid alignment returns NIL.
}

function GetMemAligned(size, alignment: PtrUInt): pointer;
  var
    raw: pointer;
    aligned_addr: PtrUInt;
  begin
    if (alignment < sizeof(pointer)) or
       ((alignment and (alignment - 1)) <> 0) then
      exit(nil);
    GetMem(raw, size + alignment + sizeof(pointer));
    if raw = nil then
      exit(nil);
    aligned_addr := (PtrUInt(raw) + sizeof(pointer) + alignment - 1) and
                    not PtrUInt(alignment - 1);
    PPointer(aligned_addr - sizeof(pointer))^ := raw;
    result := pointer(aligned_addr);
  end;


function AllocMemAligned(size, alignment: PtrUInt): pointer;
  begin
    result := GetMemAligned(size, alignment);
    if result <> nil then
      FillChar(result^, size, 0);
  end;


procedure FreeMemAligned(p: pointer);
  var
    raw: pointer;
  begin
    if p = nil then
      exit;
    raw := PPointer(PtrUInt(p) - sizeof(pointer))^;
    FreeMem(raw);
  end;


function ReAllocMemAligned(var p: pointer; new_size, alignment: PtrUInt): pointer;
{ Resize an aligned allocation. Follows the standard ReAllocMem contract:
  - p=nil + new_size>0: act as GetMemAligned
  - p<>nil + new_size=0: act as FreeMemAligned, set p to nil
  - allocation failure: free old and set p to nil (matches stock ReAllocMem)
  The new buffer is freshly aligned to `alignment` (which may differ from
  the original allocation's alignment). User data is preserved up to
  min(old_user_size, new_size) bytes. }
  var
    new_ptr, old_raw: pointer;
    old_user_size, copy_size: PtrUInt;
  begin
    if p = nil then
      begin
        p := GetMemAligned(new_size, alignment);
        result := p;
        exit;
      end;
    if new_size = 0 then
      begin
        FreeMemAligned(p);
        p := nil;
        result := nil;
        exit;
      end;
    old_raw := PPointer(PtrUInt(p) - sizeof(pointer))^;
    old_user_size := PtrUInt(old_raw) + MemSize(old_raw) - PtrUInt(p);
    new_ptr := GetMemAligned(new_size, alignment);
    if new_ptr = nil then
      begin
        FreeMemAligned(p);
        p := nil;
        result := nil;
        exit;
      end;
    if old_user_size < new_size then
      copy_size := old_user_size
    else
      copy_size := new_size;
    Move(p^, new_ptr^, copy_size);
    FreeMemAligned(p);
    p := new_ptr;
    result := new_ptr;
  end;
