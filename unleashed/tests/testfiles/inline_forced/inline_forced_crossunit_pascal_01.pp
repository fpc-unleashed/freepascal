{ %PRECOMPILE=uinline_forced_crossunit_pascal_01.pas }
program inline_forced_crossunit_pascal_01;

{$mode unleashed}

uses uinline_forced_crossunit_pascal_01;

begin
  if XuAdd(2, 3) <> 5 then
    halt(1);
end.
