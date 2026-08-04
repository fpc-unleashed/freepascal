{ %CPU=x86_64 }
program inline_forced_asm_address_taken_01;
{$mode unleashed}
{$asmmode intel}

// taking the address of a inline assembler routine is allowed: the direct
// call is spliced, the standalone body still exists for the indirect call

type
  TFn = function(a, b: longint): longint; register;

function add(a, b: longint): longint; register; assembler; nostackframe; inline;
asm
  mov eax, ecx
  add eax, edx
end;

var
  p: TFn;
begin
  if add(2, 3) <> 5 then Halt(1);     // spliced
  p := @add;
  if p(10, 20) <> 30 then Halt(2);    // indirect call through standalone body
end.
