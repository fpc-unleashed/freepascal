{ %FAIL }
program composable_records_fail_perfield_align_bitalign_exclusive_01;
{ per-field `align` and `bitalign` are mutually exclusive, same rule as
  on pre-body modifiers. specifying both is a compile error. }

{$mode unleashed}

type
  TBad = bitpacked record
    x: Byte align 4 bitalign 16;
  end;

begin
end.
