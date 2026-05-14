program stringordcast_dword_01;

{$mode unleashed}

const
  RIFF_SIG = DWord('RIFF');

begin
  // 'R'=$52 'I'=$49 'F'=$46 'F'=$46; little-endian -> $46464952
  if RIFF_SIG <> $46464952 then halt(1);
end.
