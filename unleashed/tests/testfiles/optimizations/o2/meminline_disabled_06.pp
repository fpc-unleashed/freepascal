{ %OPT="-O2 -OoNOMEMINLINE" }
program meminline_disabled_06;
{$mode unleashed}

// with the optimization switched off everything goes through the RTL
// calls and behaves identically

var
  buf: array[32] of Byte;
  dst: array[32] of Byte;

begin
  FillChar(buf, SizeOf(buf), 0);
  FillChar(buf, 24, $A5);
  for var i := 0 to 23 do if buf[i] <> $A5 then Halt(10);
  for var i := 24 to 31 do if buf[i] <> 0 then Halt(11);

  FillChar(dst, SizeOf(dst), $FF);
  Move(buf, dst, 16);
  for var i := 0 to 15 do if dst[i] <> $A5 then Halt(20);
  for var i := 16 to 31 do if dst[i] <> $FF then Halt(21);
end.
