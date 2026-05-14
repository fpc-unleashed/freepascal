program composable_records_wild_system_info_port_01;

{$mode unleashed}

type
  DWORD     = LongWord;
  WORD      = System.Word;
  DWORD_PTR = PtrUInt;
  LPVOID    = Pointer;

  TSystemInfo = record
    union
      dwOemId: DWORD;
      record
        wProcessorArchitecture: WORD;
        wReserved:              WORD;
      end;
    end;
    dwPageSize:                  DWORD;
    lpMinimumApplicationAddress: LPVOID;
    lpMaximumApplicationAddress: LPVOID;
    dwActiveProcessorMask:       DWORD_PTR;
    dwNumberOfProcessors:        DWORD;
    dwProcessorType:             DWORD;
    dwAllocationGranularity:     DWORD;
    wProcessorLevel:             WORD;
    wProcessorRevision:          WORD;
  end;

var
  si: TSystemInfo;
begin
  si.dwOemId := $00090005;
  { union overlay: writing dwOemId fills both 16-bit halves }
  if si.wProcessorArchitecture <> 5 then halt(1);
  if si.wReserved              <> 9 then halt(2);
  si.dwPageSize := 4096;
  if si.dwPageSize <> 4096 then halt(3);
end.
