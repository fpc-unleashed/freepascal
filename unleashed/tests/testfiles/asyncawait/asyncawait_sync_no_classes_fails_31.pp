{ %FAIL }
{ a sync block without the Classes unit has nothing to lower to }
program asyncawait_sync_no_classes_fails_31;
{$mode unleashed}
begin
  sync begin end;
end.
