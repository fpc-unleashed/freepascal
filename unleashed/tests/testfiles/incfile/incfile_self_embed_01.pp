program incfile_self_embed_01;
{$mode unleashed}

// directive embeds its own source file; the marker below must round-trip
// through the bin2pas encoder back into the runtime const
{$incfile src 'incfile_self_embed_01.pp'}

const
  Marker = 'INCFILE_X73K9P2_MARKER';
begin
  if length(src) < 100 then halt(1);
  if pos(Marker, src) = 0 then halt(2);
  // file ends with `end.`+LF, content must include both
  if pos('end.', src) = 0 then halt(3);
end.
