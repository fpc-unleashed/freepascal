program tuple_match_with_named_pattern_01;

{$mode unleashed}

function What(p: (x, y: Integer)): String;
begin
  match p of
    (0, 0): Result := 'origin';
    (1, _): Result := 'first-row';
    (_, 1): Result := 'first-col';
    _:      Result := 'other';
  end;
end;

begin
  if What((x: 0, y: 0)) <> 'origin'    then halt(1);
  if What((x: 1, y: 5)) <> 'first-row' then halt(2);
  if What((x: 5, y: 1)) <> 'first-col' then halt(3);
  if What((x: 7, y: 7)) <> 'other'     then halt(4);
end.
