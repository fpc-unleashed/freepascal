{ %OPT=-O2 }
program meminline_nonconst_count_07;
{$mode unleashed}

// runtime counts and values keep the RTL call; zero and negative constant
// counts write nothing; a runtime fill value works through the call

var
  buf: array[32] of Byte;
  n: Integer;
  v: Byte;

begin
  FillChar(buf, SizeOf(buf), 0);
  n := 13;
  FillChar(buf, n, $77);
  for var i := 0 to 12 do if buf[i] <> $77 then Halt(10);
  for var i := 13 to 31 do if buf[i] <> 0 then Halt(11);

  FillChar(buf, 0, $FF);
  if buf[0] <> $77 then Halt(20);

  v := $C3;
  FillChar(buf, 4, v);
  for var i := 0 to 3 do if buf[i] <> $C3 then Halt(30);
  if buf[4] <> $77 then Halt(31);
end.
