{ %CPU=x86_64 }
program inline_forced_mixed_asm_01;
{$mode unleashed}
{$asmmode intel}

// a Pascal body with an embedded asm statement is expandable under forced
// inline (stock inline rejects any assembler block)

procedure store(out d: dword); inline;
var
  tmp: dword;
begin
  asm
    mov [tmp], 123
  end;
  d := tmp;
end;

var
  v: dword;
begin
  store(v);
  if v <> 123 then Halt(1);
end.
