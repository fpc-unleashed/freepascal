program composable_records_pointer_getmem_aligned_01;

{$mode unleashed}

type
  TCacheLine = record
    counter: QWord align 64;
    flag: Boolean;
  end;
  PCacheLine = ^TCacheLine;

var
  p: PCacheLine;
begin
  p := GetMemAligned(SizeOf(TCacheLine), 64);
  try
    if (PtrUInt(p) and 63) <> 0 then halt(1);
    p^.counter := $1122334455667788;
    p^.flag := True;
    if p^.counter <> $1122334455667788 then halt(2);
    if not p^.flag then halt(3);
  finally
    FreeMemAligned(p);
  end;
end.
