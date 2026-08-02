{ %OPT=-O2 }
program meminline_move_03;
{$mode unleashed}

// constant-count Move: payload correctness with guard zones, plus
// overlapping ranges in both directions (memmove semantics)

var
  src: array[80] of Byte;
  dst: record guard1: QWord; data: array[72] of Byte; guard2: QWord; end;
  buf: array[64] of Byte;

procedure InitDst;
begin
  dst.guard1 := QWord($4444444444444444); dst.guard2 := dst.guard1;
  for var i := 0 to 71 do dst.data[i] := $99;
end;

procedure CheckDst(n, code: Integer);
begin
  for var i := 0 to n - 1 do if dst.data[i] <> i + 1 then Halt(code);
  for var i := n to 71 do if dst.data[i] <> $99 then Halt(code + 1);
  if (dst.guard1 <> QWord($4444444444444444)) or (dst.guard2 <> QWord($4444444444444444)) then Halt(code + 2);
end;

begin
  for var i := 0 to 79 do src[i] := i + 1;

  InitDst; Move(src, dst.data, 1); CheckDst(1, 10);
  InitDst; Move(src, dst.data, 2); CheckDst(2, 20);
  InitDst; Move(src, dst.data, 3); CheckDst(3, 30);
  InitDst; Move(src, dst.data, 4); CheckDst(4, 40);
  InitDst; Move(src, dst.data, 5); CheckDst(5, 50);
  InitDst; Move(src, dst.data, 7); CheckDst(7, 60);
  InitDst; Move(src, dst.data, 8); CheckDst(8, 70);
  InitDst; Move(src, dst.data, 9); CheckDst(9, 80);
  InitDst; Move(src, dst.data, 15); CheckDst(15, 90);
  InitDst; Move(src, dst.data, 16); CheckDst(16, 100);
  InitDst; Move(src, dst.data, 17); CheckDst(17, 110);
  InitDst; Move(src, dst.data, 24); CheckDst(24, 120);
  InitDst; Move(src, dst.data, 31); CheckDst(31, 130);
  InitDst; Move(src, dst.data, 32); CheckDst(32, 140);
  InitDst; Move(src, dst.data, 33); CheckDst(33, 150);
  InitDst; Move(src, dst.data, 47); CheckDst(47, 160);
  InitDst; Move(src, dst.data, 48); CheckDst(48, 170);
  InitDst; Move(src, dst.data, 63); CheckDst(63, 180);
  InitDst; Move(src, dst.data, 64); CheckDst(64, 190);
  // over the cap: RTL call, same behavior
  InitDst; Move(src, dst.data, 65); CheckDst(65, 200);

  // forward overlap: dst > src
  for var i := 0 to 63 do buf[i] := i;
  Move(buf[0], buf[3], 16);
  for var i := 0 to 15 do if buf[3 + i] <> i then Halt(200);

  // backward overlap: dst < src
  for var i := 0 to 63 do buf[i] := i;
  Move(buf[5], buf[0], 24);
  for var i := 0 to 23 do if buf[i] <> 5 + i then Halt(210);

  // complete overlap is an identity
  for var i := 0 to 63 do buf[i] := 200 - i;
  Move(buf[8], buf[8], 32);
  for var i := 0 to 63 do if buf[i] <> 200 - i then Halt(220);
end.
