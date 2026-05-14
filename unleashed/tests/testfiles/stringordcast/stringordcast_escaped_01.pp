program stringordcast_escaped_01;

{$mode unleashed}

const
  HEX_DEAD = DWord(#$DE#$AD#$BE#$EF);

begin
  // bytes DE AD BE EF in source order; little-endian DWord -> $EFBEADDE
  if HEX_DEAD <> $EFBEADDE then halt(1);
end.
