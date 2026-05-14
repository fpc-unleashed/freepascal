program compound_bitwise_01;

{$mode unleashed}

begin
  var flags: LongWord := $FF;
  flags and= $0F;
  if flags <> $0F then halt(1);

  flags := 0;
  flags or= $30;
  if flags <> $30 then halt(2);

  flags := $FF;
  flags xor= $0F;
  if flags <> $F0 then halt(3);
end.
