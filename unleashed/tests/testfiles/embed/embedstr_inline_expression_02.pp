program embedstr_inline_expression_02;
{$mode unleashed}

// 1-arg $embedstr is a bare String expression usable inline
begin
  if length({$embedstr 'embedstr_inline_expression_02.pp'}) < 100 then halt(1);
  if pos('INLINE_X73K9P2_MARKER', {$embedstr 'embedstr_inline_expression_02.pp'}) = 0 then halt(2);
end.
