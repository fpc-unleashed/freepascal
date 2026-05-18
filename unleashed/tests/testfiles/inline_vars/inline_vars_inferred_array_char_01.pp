program inline_vars_inferred_array_char_01;
{$mode unleashed}

// single-char literals get promoted to AnsiString (consistent with
// var s := 'x' -> String, not Char) so subsequent multi-char elements
// fit without ambiguity

begin
  var a := ['a', 'bb', 'ccc'];
  if Length(a) <> 3 then halt(1);
  if a[0] <> 'a' then halt(2);
  if a[1] <> 'bb' then halt(3);
  if a[2] <> 'ccc' then halt(4);
  if Length(a[2]) <> 3 then halt(5);
  if SizeOf(a[0]) <> SizeOf(AnsiString) then halt(6);
end.
