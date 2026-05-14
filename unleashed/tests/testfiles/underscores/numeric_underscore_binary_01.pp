program numeric_underscore_binary_01;

{$mode unleashed}

begin
  var byte_pattern := %1010_0011;
  if byte_pattern <> $A3 then halt(1);

  var word_pattern := %0000_0001_0000_0010;
  if word_pattern <> $0102 then halt(2);
end.
