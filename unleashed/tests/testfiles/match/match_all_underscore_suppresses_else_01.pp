program match_all_underscore_suppresses_else_01;
// `_` counts as a match, so the trailing else can never run
// (the compiler warns about the dead else branch)

{$mode unleashed}

var
  hits, wild, fallback: Integer;

begin
  hits := 0;
  wild := 0;
  fallback := 0;
  match all 7 of
    5: Inc(hits);
    3: Inc(hits);
    _: Inc(wild);
    else Inc(fallback);
  end;
  if hits <> 0 then halt(1);
  if wild <> 1 then halt(2);
  if fallback <> 0 then halt(3);

  // same with a concrete match before the wildcard
  hits := 0;
  wild := 0;
  fallback := 0;
  match all 5 of
    5: Inc(hits);
    _: Inc(wild);
    otherwise Inc(fallback);
  end;
  if hits <> 1 then halt(4);
  if wild <> 1 then halt(5);
  if fallback <> 0 then halt(6);
end.
