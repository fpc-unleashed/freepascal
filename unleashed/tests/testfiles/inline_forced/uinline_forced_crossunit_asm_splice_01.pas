unit uinline_forced_crossunit_asm_splice_01;

{$mode unleashed}
{$asmmode intel}

interface

function XuAsmAdd(a, b: DWord): DWord; inline;

implementation

// intel-order source: the internal assembler swaps the operands in place
// while assembling the standalone body, so the ppu image used to leak
// intel order and the spliced copy computed garbage at the call site
function XuAsmAdd(a, b: DWord): DWord; assembler; nostackframe;
asm
  mov eax, ecx
  add eax, edx
end;

end.
