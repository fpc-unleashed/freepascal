{ %PRECOMPILE=uinline_forced_crossunit_asm_framed_01.pas %CPU=x86_64 }
{ a framed assembler routine cannot be inlined; the flag survives the ppu
  roundtrip and the call site falls back to a regular call }
program inline_forced_crossunit_asm_framed_fallback_01;

{$mode unleashed}

uses uinline_forced_crossunit_asm_framed_01;

begin
  if XuFramed(20, 22) <> 42 then
    halt(1);
end.
