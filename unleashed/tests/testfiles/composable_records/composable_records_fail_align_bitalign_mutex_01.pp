{ %FAIL }
program composable_records_fail_align_bitalign_mutex_01;

{$mode unleashed}

type
  TRec = bitpacked record of Byte align 4 bitalign 16
    a: 1;
  end;
begin
end.
