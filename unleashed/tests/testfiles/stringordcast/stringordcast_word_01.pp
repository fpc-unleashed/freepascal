program stringordcast_word_01;

{$mode unleashed}

const
  MZ_SIG = Word('MZ');

begin
  // 'M' = $4D, 'Z' = $5A; little-endian Word: 'M' is low byte, 'Z' high
  if MZ_SIG <> $5A4D then halt(1);
end.
