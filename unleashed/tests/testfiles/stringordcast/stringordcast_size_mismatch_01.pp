{ %FAIL }
program stringordcast_size_mismatch_01;

{$mode unleashed}

const
  // 'ABC' is 3 bytes, but Word is 2 bytes
  X = Word('ABC');

begin
end.
