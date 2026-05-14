program inline_vars_char_promotion_01;

{$mode unleashed}

begin
  // single-character literal infers to String, not Char
  var s := 'a';
  if Length(s) <> 1 then halt(1);
  s := s + 'bc';
  if s <> 'abc' then halt(2);

  // explicit cast preserves Char
  var c := Char('a');
  if SizeOf(c) <> SizeOf(Char) then halt(3);
end.
