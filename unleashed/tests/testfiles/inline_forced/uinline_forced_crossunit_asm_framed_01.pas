unit uinline_forced_crossunit_asm_framed_01;

{$mode unleashed}
{$asmmode intel}

interface

function XuFramed(a, b: DWord): DWord; inline;

implementation

function XuFramed(a, b: DWord): DWord; assembler;
asm
  mov eax, ecx
  add eax, edx
end;

end.
