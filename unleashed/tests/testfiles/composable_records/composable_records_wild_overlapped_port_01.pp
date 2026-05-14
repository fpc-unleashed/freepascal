program composable_records_wild_overlapped_port_01;

{$mode unleashed}

type
  DWORD     = LongWord;
  ULONG_PTR = PtrUInt;
  HANDLE    = Pointer;
  PVOID     = Pointer;

  TOverlapped = record
    Internal:     ULONG_PTR;
    InternalHigh: ULONG_PTR;
    union
      record
        Offset, OffsetHigh: DWORD;
      end;
      Pointer: PVOID;
    end;
    hEvent: HANDLE;
  end;

var
  ov: TOverlapped;
begin
  ov.Internal     := 0;
  ov.InternalHigh := 0;
  ov.Offset       := $1000;
  ov.OffsetHigh   := $2000;
  ov.hEvent       := nil;
  if ov.Offset     <> $1000 then halt(1);
  if ov.OffsetHigh <> $2000 then halt(2);

  { same storage via the pointer alias }
  ov.Pointer := PVOID(PtrUInt($0000200000001000));
  if ov.Offset     <> $1000 then halt(3);
  if ov.OffsetHigh <> $2000 then halt(4);
end.
