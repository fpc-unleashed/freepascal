program lock_outside_unleashed_is_ident_01;
{$mode objfpc}

// outside `m_lock` the words `lock` and `trylock` stay plain identifiers
// (`wait` is context-sensitive and never reserved anywhere) - existing
// code that happens to use them is not broken
var
  lock: Integer;
  trylock: Integer;
  wait: Integer;
begin
  lock := 42;
  trylock := 7;
  wait := lock + trylock;
  if lock <> 42 then halt(1);
  if trylock <> 7 then halt(2);
  if wait <> 49 then halt(3);
end.
