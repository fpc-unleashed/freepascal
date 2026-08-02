{ %OPT=-O2 }
program meminline_targets_05;
{$mode unleashed}

// expansion targets beyond plain locals: records, dynamic array elements,
// pointer dereferences, ansistring elements (copy-on-write), threadvars

type
  TRec16 = record a, b: Int64; end;
  TRec24 = record a, b, c: Int64; end;

threadvar tvbuf: array[16] of Byte;

var
  r16: TRec16;
  r24: TRec24;
  darr: array of Byte;
  p: PByte;
  s: AnsiString;

begin
  r16.a := -1; r16.b := -1;
  FillChar(r16, SizeOf(r16), 0);
  if (r16.a <> 0) or (r16.b <> 0) then Halt(10);

  r24.a := -1; r24.b := -1; r24.c := -1;
  FillChar(r24, SizeOf(r24), 0);
  if (r24.a <> 0) or (r24.b <> 0) or (r24.c <> 0) then Halt(11);

  SetLength(darr, 64);
  for var i := 0 to 63 do darr[i] := $EE;
  FillChar(darr[10], 12, $3C);
  for var i := 0 to 63 do
    if (i >= 10) and (i <= 21) then begin
      if darr[i] <> $3C then Halt(20);
    end else if darr[i] <> $EE then Halt(21);

  GetMem(p, 32);
  FillChar(p^, 32, $D2);
  for var i := 0 to 31 do if p[i] <> $D2 then Halt(30);
  FreeMem(p);

  // writing through s[1] must still trigger copy-on-write
  s := 'AAAABBBBCCCC';
  var s2 := s;
  FillChar(s2[1], 4, Ord('Z'));
  if s2 <> 'ZZZZBBBBCCCC' then Halt(40);
  if s <> 'AAAABBBBCCCC' then Halt(41);

  FillChar(tvbuf, SizeOf(tvbuf), $42);
  for var i := 0 to 15 do if tvbuf[i] <> $42 then Halt(50);

  // record copy through Move
  r24.a := 111; r24.b := 222; r24.c := 333;
  Move(r24, r16, 16);
  if (r16.a <> 111) or (r16.b <> 222) then Halt(60);
end.
