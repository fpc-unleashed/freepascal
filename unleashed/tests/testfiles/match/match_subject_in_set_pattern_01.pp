program match_subject_in_set_pattern_01;

{$mode unleashed}

function ClassifyChar(c: Char): String;
begin
  match c of
    'a'..'z': Result := 'lower';
    'A'..'Z': Result := 'upper';
    '0'..'9': Result := 'digit';
    _:        Result := 'other';
  end;
end;

begin
  if ClassifyChar('m') <> 'lower' then halt(1);
  if ClassifyChar('M') <> 'upper' then halt(2);
  if ClassifyChar('5') <> 'digit' then halt(3);
  if ClassifyChar('!') <> 'other' then halt(4);
end.
