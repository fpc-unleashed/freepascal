program lock_multi_vars_01;
{$mode unleashed}

var
  a, b, c: Integer;

begin
  a := 0; b := 0; c := 0;
  lock(a, b, c) do begin
    Inc(a);
    Inc(b);
    Inc(c);
  end;
  // order should not matter at the source level - the compiler
  // sorts internally so AB-vs-BA is impossible
  lock(c, a, b) do begin
    Inc(a, 2);
    Inc(b, 2);
    Inc(c, 2);
  end;
  if a <> 3 then halt(1);
  if b <> 3 then halt(2);
  if c <> 3 then halt(3);
end.
