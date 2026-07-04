program parallelfor_chunk_ident_27;
{$mode unleashed}
// `chunk` stays an ordinary identifier outside a parallel header
var chunk, s: Integer;
begin
  s := 0;
  for chunk := 1 to 5 do s := s + chunk;
  if s <> 15 then halt(1);
end.
