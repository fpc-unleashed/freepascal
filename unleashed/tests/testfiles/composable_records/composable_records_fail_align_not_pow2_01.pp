{ %FAIL }
program composable_records_fail_align_not_pow2_01;

{$mode unleashed}

type
  TRec = record align 3   { align must be a positive power of 2 }
    a: Byte;
  end;
begin
end.
