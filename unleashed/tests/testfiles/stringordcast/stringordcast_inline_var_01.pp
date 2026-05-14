program stringordcast_inline_var_01;

{$mode unleashed}

begin
  var sig := DWord('RIFF');
  if sig <> $46464952 then halt(1);
end.
