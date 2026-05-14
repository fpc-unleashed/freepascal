program stringordcast_global_var_init_01;

{$mode unleashed}

var
  g: DWord = DWord('abcd');

begin
  // 'a'=$61 'b'=$62 'c'=$63 'd'=$64; little-endian DWord: $64636261
  if g <> $64636261 then halt(1);
end.
