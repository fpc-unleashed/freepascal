{ %FAIL }

// dword('abc') - 3 chars to 4-byte type must fail with specific diagnostic:
// "Cannot cast string of length 3 to ordinal type ""LongWord"" (size 4 bytes)"
// and must not produce a cascading "Illegal expression" second error

program stringordcast_fail_short_string_dword_01;

{$mode unleashed}

const
  bad = dword('abc');

begin
end.
