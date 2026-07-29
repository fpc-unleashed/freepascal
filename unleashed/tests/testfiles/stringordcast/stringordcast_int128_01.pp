program stringordcast_int128_01;

{$mode unleashed}

const
  MAGIC_128 = Int128('abcdefghijklmnop');
  ALL_FF = Int128(#$FF#$FF#$FF#$FF#$FF#$FF#$FF#$FF#$FF#$FF#$FF#$FF#$FF#$FF#$FF#$FF);

begin
  // 'a'..'p' = $61..$70; little-endian Int128: $706F6E6D6C6B6A696867666564636261
  if MAGIC_128 <> $706F6E6D6C6B6A696867666564636261 then halt(1);
  // sixteen $FF bytes are the two's complement pattern of -1
  if ALL_FF <> -1 then halt(2);
end.
