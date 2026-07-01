program trylock_multi_vars_01;
{$mode unleashed}

var
  a, b, c: Integer;

begin
  a := 0; b := 0; c := 0;
  // all-or-nothing on three free locks
  trylock(a, b, c) wait 100 do
  begin
    Inc(a); Inc(b); Inc(c);
  end
  else halt(1);
  if (a <> 1) or (b <> 1) or (c <> 1) then halt(2);
  // different source order resolves to the same sorted lock order
  trylock(c, a) wait 100 do
  begin
    Inc(a); Inc(c);
  end
  else halt(3);
  if (a <> 2) or (c <> 2) then halt(4);
end.
