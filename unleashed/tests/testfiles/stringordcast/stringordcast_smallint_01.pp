program stringordcast_smallint_01;

{$mode unleashed}

const
  TWO = SmallInt('AB');

begin
  // 'A'=$41, 'B'=$42; little-endian SmallInt: $4241
  if Word(TWO) <> $4241 then halt(1);
end.
