program embedbytes_self_embed_01;
{$mode unleashed}

// 2-arg $embedbytes embeds its own source as array[0..N-1] of byte
{$embedbytes src 'embedbytes_self_embed_01.pp'}

const
  Marker = 'EMBEDBYTES_X73K9P2_MARKER';

var
  i, j: integer;
  hit: boolean;
begin
  if length(src) < 100 then halt(1);
  for i := 0 to length(src) - length(Marker) do begin
    hit := true;
    for j := 1 to length(Marker) do
      if char(src[i + j - 1]) <> Marker[j] then begin
        hit := false;
        break;
      end;
    if hit then exit;
  end;
  halt(2);
end.
