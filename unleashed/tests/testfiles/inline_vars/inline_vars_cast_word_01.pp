program inline_vars_cast_word_01;
{$mode unleashed}

// explicit Word cast keeps the variable at 2 bytes (16-bit unsigned),
// no promotion to LongInt

begin
  var w := Word(1000);
  if SizeOf(w) <> SizeOf(Word) then halt(1);
  if SizeOf(w) <> 2 then halt(2);
  if w <> 1000 then halt(3);
end.
