{ %PRECOMPILE=uinline_forced_crossunit_asm_splice_01.pas %CPU=x86_64 }
program inline_forced_crossunit_asm_splice_01;

{$mode unleashed}

uses uinline_forced_crossunit_asm_splice_01;

var
  r: DWord;
begin
  r := XuAsmAdd(20, 22);
  if r <> 42 then
    halt(1);
end.
