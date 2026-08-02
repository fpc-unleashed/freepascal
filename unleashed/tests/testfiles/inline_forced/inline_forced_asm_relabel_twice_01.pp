program inline_forced_asm_relabel_twice_01;
{$mode unleashed}
{$asmmode intel}

// body with a local label and branch; calling it twice in one routine forces
// the splice to relabel the local label per expansion (otherwise: duplicate
// label / wrong control flow)

function clamp_nonneg(x: longint): longint; register; assembler; nostackframe; inline;
asm
  mov eax, ecx
  test eax, eax
  jns @@done
  xor eax, eax
@@done:
end;

begin
  // two expansions in the same routine -> two copies of @@done
  if clamp_nonneg(5) <> 5 then Halt(1);
  if clamp_nonneg(-3) <> 0 then Halt(2);
  if clamp_nonneg(-1) + clamp_nonneg(9) <> 9 then Halt(3);
end.
