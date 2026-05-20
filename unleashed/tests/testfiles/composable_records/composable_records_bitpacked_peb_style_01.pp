program composable_records_bitpacked_peb_style_01;

{$mode unleashed}

type
  TPEBHead = packed record
    InheritedAddressSpace, ReadImageFileExecOptions,
    BeingDebugged: Byte;
    union of Byte size 1
      BitField: Byte;
      bitpacked record of Boolean
        ImageUsesLargePages, IsProtectedProcess, IsImageDynamicallyRelocated,
        SkipPatchingUser32Forwarders, IsPackagedProcess, IsAppContainer,
        IsProtectedProcessLight, IsLongPathAwareProcess: 1;
      end;
    end;
  end;

begin
  { the C `_PEB` head: 3 bytes + 1 byte union = 4 bytes }
  if SizeOf(TPEBHead) <> 4 then halt(1);
end.
