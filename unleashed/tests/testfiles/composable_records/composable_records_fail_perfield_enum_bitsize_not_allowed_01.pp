{ %FAIL }
program composable_records_fail_perfield_enum_bitsize_not_allowed_01;
{ per-field `bitsize N` is rejected outright on an enum field, regardless
  of the bit count. enum storage is controlled via `(...) of T` only. }

{$mode unleashed}

type
  TKind = (kA, kB, kC, kD);
  TBad = bitpacked record
    kind: TKind bitsize 8;
  end;

begin
end.
