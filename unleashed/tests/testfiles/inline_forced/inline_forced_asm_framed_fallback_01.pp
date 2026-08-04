{ %CPU=x86_64 }
program inline_forced_asm_framed_fallback_01;
{$mode unleashed}
{$asmmode intel}

// a pure assembler routine must be nostackframe to be inlined: with a stack
// frame the body has frame-relative references that do not survive the
// splice, so the call stays a regular call (with a warning)

function f(a: longint): longint; register; assembler; inline;
asm
  mov eax, ecx
end;

begin
  if f(42) <> 42 then Halt(1);
end.
