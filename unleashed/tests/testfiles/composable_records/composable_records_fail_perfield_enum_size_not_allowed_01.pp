{ %FAIL }
program composable_records_fail_perfield_enum_size_not_allowed_01;
{ per-field `size N` is rejected outright on an enum field, regardless of
  the size value. enum storage is controlled via `(...) of T` only. }

{$mode unleashed}

type
  TKind = (kAudio, kVideo, kCtrl);
  TBad = record
    kind: TKind size 8;
  end;

begin
end.
