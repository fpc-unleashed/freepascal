{ %FAIL }
program defer_in_asm_rejected_01;

{$mode unleashed}

procedure DoWork; assembler;
asm
  defer Writeln('cleanup');   // defer is forbidden inside asm..end
end;

begin
end.
