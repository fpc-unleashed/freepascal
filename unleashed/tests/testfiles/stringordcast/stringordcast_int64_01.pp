program stringordcast_int64_01;

{$mode unleashed}

const
  EIGHT = Int64('12345678');

begin
  // '1'=$31 '2'=$32 ... '8'=$38; little-endian Int64: $3837363534333231
  if QWord(EIGHT) <> $3837363534333231 then halt(1);
end.
