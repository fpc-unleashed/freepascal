program stringordcast_byte_01;

{$mode unleashed}

const
  ESC = Byte(#27);
  ZERO = Byte('0');

begin
  if ESC  <> 27   then halt(1);
  if ZERO <> $30  then halt(2);
end.
