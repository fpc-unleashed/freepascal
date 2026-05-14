program stringordcast_used_at_runtime_01;

{$mode unleashed}

const
  RIFF_SIG = DWord('RIFF');
  WAVE_SIG = DWord('WAVE');

var
  buf: array[0..7] of Byte = ($52, $49, $46, $46, $57, $41, $56, $45);

begin
  // first 4 bytes = 'RIFF'; PDWord(@buf[0])^ should match RIFF_SIG
  if PDWord(@buf[0])^ <> RIFF_SIG then halt(1);
  if PDWord(@buf[4])^ <> WAVE_SIG then halt(2);
end.
