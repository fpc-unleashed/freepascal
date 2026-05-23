{ %FAIL }
program composable_records_fail_anon_enum_of_overflow_01;
{ enum value 300 does not fit in Byte storage (max 255). compile error
  at the storage-type clause. }

{$mode unleashed}

type
  TBad = record
    kind: (k0 = 0, k_huge = 300) of Byte;
  end;

begin
end.
