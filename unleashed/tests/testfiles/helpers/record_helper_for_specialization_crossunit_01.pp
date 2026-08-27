{ %PRECOMPILE=urecord_helper_for_specialization_crossunit_01.pas }
program record_helper_for_specialization_crossunit_01;

{$mode unleashed}

uses urecord_helper_for_specialization_crossunit_01;

begin
  var w: TWrap<LongInt>;
  w.val := 1;
  w.bump;
  if w.val <> 2 then halt(1);
end.
