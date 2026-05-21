{ %FAIL }
program composable_records_fail_perfield_duplicate_modifier_01;
{ each per-field modifier appears at most once, same rule as on
  pre-body modifiers. repeating a modifier is a compile error. }

{$mode unleashed}

type
  TBad = record
    x: Integer align 4 align 8;
  end;

begin
end.
