program numeric_underscore_hex_01;

{$mode unleashed}

begin
  var mask := $FF_FF_00_00;
  if mask <> $FFFF0000 then halt(1);

  var word_mask := $00_FF;
  if word_mask <> $00FF then halt(2);
end.
