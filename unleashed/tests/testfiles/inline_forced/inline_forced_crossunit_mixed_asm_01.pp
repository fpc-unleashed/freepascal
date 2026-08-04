{ %PRECOMPILE=uinline_forced_crossunit_mixed_asm_01.pas %CPU=x86_64 }
program inline_forced_crossunit_mixed_asm_01;

{$mode unleashed}

uses uinline_forced_crossunit_mixed_asm_01;

begin
  if MixedVal <> 123 then
    halt(1);
end.
