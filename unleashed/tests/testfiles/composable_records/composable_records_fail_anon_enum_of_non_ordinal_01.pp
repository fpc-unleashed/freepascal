{ %FAIL }
program composable_records_fail_anon_enum_of_non_ordinal_01;
{ `of T` storage type must be ordinal. `Single` is not. }

{$mode unleashed}

type
  TBad = record
    kind: (kA, kB) of Single;
  end;

begin
end.
