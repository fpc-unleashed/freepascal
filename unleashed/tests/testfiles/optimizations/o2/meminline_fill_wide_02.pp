{ %OPT=-O2 }
program meminline_fill_wide_02;
{$mode unleashed}

// FillByte/FillWord/FillDWord/FillQWord with constant counts: pattern
// replication, little-endian byte order, cap boundary (64 bytes)

var
  bytes: array[80] of Byte;
  words: packed record pre: QWord; w: array[16] of Word; post: QWord; end;
  dwords: packed record pre: QWord; d: array[8] of DWord; post: QWord; end;
  qwords: packed record pre: QWord; q: array[10] of QWord; post: QWord; end;

begin
  FillChar(bytes, SizeOf(bytes), 0);
  FillByte(bytes, 7, $5A);
  for var i := 0 to 6 do if bytes[i] <> $5A then Halt(10);
  if bytes[7] <> 0 then Halt(11);

  words.pre := QWord($1111111111111111); words.post := words.pre;
  FillChar(words.w, SizeOf(words.w), 0);
  FillWord(words.w, 7, $BEEF);
  for var i := 0 to 6 do if words.w[i] <> $BEEF then Halt(20);
  if words.w[7] <> 0 then Halt(21);
  if (words.pre <> QWord($1111111111111111)) or (words.post <> QWord($1111111111111111)) then Halt(22);
  // byte order in memory
  if PByte(@words.w[0])^ <> $EF then Halt(23);
  if PByte(@words.w[0])[1] <> $BE then Halt(24);

  dwords.pre := QWord($2222222222222222); dwords.post := dwords.pre;
  FillChar(dwords.d, SizeOf(dwords.d), 0);
  FillDWord(dwords.d, 5, $DEADBEEF);
  for var i := 0 to 4 do if dwords.d[i] <> $DEADBEEF then Halt(30);
  if dwords.d[5] <> 0 then Halt(31);
  if (dwords.pre <> QWord($2222222222222222)) or (dwords.post <> QWord($2222222222222222)) then Halt(32);

  qwords.pre := QWord($3333333333333333); qwords.post := qwords.pre;
  FillChar(qwords.q, SizeOf(qwords.q), 0);
  // count 8 = 64 bytes, right at the expansion cap
  FillQWord(qwords.q, 8, QWord($0123456789ABCDEF));
  for var i := 0 to 7 do if qwords.q[i] <> QWord($0123456789ABCDEF) then Halt(40);
  if qwords.q[8] <> 0 then Halt(41);
  // count 9 = 72 bytes, over the cap: stays an RTL call, same behavior
  FillQWord(qwords.q, 9, QWord($FEDCBA9876543210));
  for var i := 0 to 8 do if qwords.q[i] <> QWord($FEDCBA9876543210) then Halt(42);
  if qwords.q[9] <> 0 then Halt(43);
  if (qwords.pre <> QWord($3333333333333333)) or (qwords.post <> QWord($3333333333333333)) then Halt(44);
end.
