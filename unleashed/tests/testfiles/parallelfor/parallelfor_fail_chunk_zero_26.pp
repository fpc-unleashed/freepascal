{ %FAIL }
program parallelfor_fail_chunk_zero_26;
{$mode unleashed}
// a constant chunk must be positive
begin
  for parallel var i := 1 to 10 chunk 0 do ;
end.
