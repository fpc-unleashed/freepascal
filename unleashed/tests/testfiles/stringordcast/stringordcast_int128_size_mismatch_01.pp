{ %FAIL }
program stringordcast_int128_size_mismatch_01;

{$mode unleashed}

const
  // 'RIFF' is 4 bytes, but Int128 is 16 bytes
  X = Int128('RIFF');

begin
end.
