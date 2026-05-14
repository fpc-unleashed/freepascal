program stringordcast_longint_01;

{$mode unleashed}

const
  FOUR = LongInt('WAVE');

begin
  // 'W'=$57 'A'=$41 'V'=$56 'E'=$45; little-endian LongInt: $45564157
  if LongWord(FOUR) <> $45564157 then halt(1);
end.
