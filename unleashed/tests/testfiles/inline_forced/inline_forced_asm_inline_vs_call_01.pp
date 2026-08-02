program inline_forced_asm_inline_vs_call_01;
{$mode unleashed}
{$asmmode intel}

// a inline assembler routine is spliced at the call site; its result must
// match the same body called normally, across all argument combinations

function mix_inl(a, b, c: longint): longint; register; assembler; nostackframe; inline;
asm
  // win64 register abi: ecx=a, edx=b, r8d=c
  mov eax, ecx
  imul eax, edx
  add eax, r8d
  sub eax, 7
end;

function mix_call(a, b, c: longint): longint; register; assembler; nostackframe;
asm
  mov eax, ecx
  imul eax, edx
  add eax, r8d
  sub eax, 7
end;

var
  i, j, k: longint;
begin
  for i := -4 to 4 do
    for j := -4 to 4 do
      for k := -4 to 4 do
        if mix_inl(i, j, k) <> mix_call(i, j, k) then
          Halt(1);
end.
