program composable_records_wild_peb_full_01;

{$mode unleashed}

type
  TPEBHead = packed record
    InheritedAddressSpace: Byte;
    ReadImageFileExecOptions: Byte;
    BeingDebugged: Byte;
    union of Byte size 1
      BitField: Byte;
      bitpacked record of Boolean
        ImageUsesLargePages: 1;
        IsProtectedProcess: 1;
        IsImageDynamicallyRelocated: 1;
        SkipPatchingUser32Forwarders: 1;
        IsPackagedProcess: 1;
        IsAppContainer: 1;
        IsProtectedProcessLight: 1;
        IsLongPathAwareProcess: 1;
      end;
    end;
  end;

var
  peb: TPEBHead;
begin
  if SizeOf(TPEBHead) <> 4 then halt(1);
  peb.BitField := $00;
  peb.IsAppContainer := True;
  if peb.BitField <> $20 then halt(2);    { bit 5 set }
  peb.IsProtectedProcess := True;
  if peb.BitField <> $22 then halt(3);    { bit 1 + bit 5 }
end.
