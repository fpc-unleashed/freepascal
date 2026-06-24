program embedstr_self_embed_01;
{$mode unleashed}

// 2-arg $embedstr embeds its own source as a String; the marker below
// must round-trip into the runtime const
{$embedstr src 'embedstr_self_embed_01.pp'}

const
  Marker = 'EMBEDSTR_X73K9P2_MARKER';
begin
  if length(src) < 100 then halt(1);
  if pos(Marker, src) = 0 then halt(2);
  if pos('end.', src) = 0 then halt(3);
end.
