{ async spawned (and awaited) inside a unit's initialization section }
program asyncawait_unit_initialization_16;
{$mode unleashed}
uses asyncawait_unitinit_helper;
begin
  if ready <> 7 then halt(1);
end.
