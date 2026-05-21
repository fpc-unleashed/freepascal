{ %FAIL }
program composable_records_fail_perfield_size_bitsize_exclusive_01;
{ per-field `size` and `bitsize` are mutually exclusive, same rule as
  on pre-body modifiers. specifying both is a compile error. }

{$mode unleashed}

type
  TBad = record
    x: Integer size 8 bitsize 16;
  end;

begin
end.
