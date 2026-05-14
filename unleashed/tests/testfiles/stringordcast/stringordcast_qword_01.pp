program stringordcast_qword_01;

{$mode unleashed}

const
  MAGIC_64 = QWord('abcdefgh');

begin
  // 'a'=$61 'b'=$62 'c'=$63 'd'=$64 'e'=$65 'f'=$66 'g'=$67 'h'=$68
  // little-endian QWord: $6867666564636261
  if MAGIC_64 <> $6867666564636261 then halt(1);
end.
