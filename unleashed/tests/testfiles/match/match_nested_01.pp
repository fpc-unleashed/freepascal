program match_nested_01;

{$mode unleashed}

function ClassifyPair(a, b: Integer): String;
begin
  match a of
    0:
      match b of
        0: Result := 'origin';
        _: Result := 'on-y';
      end;
    _:
      match b of
        0: Result := 'on-x';
        _: Result := 'somewhere';
      end;
  end;
end;

begin
  if ClassifyPair(0, 0) <> 'origin'    then halt(1);
  if ClassifyPair(0, 5) <> 'on-y'      then halt(2);
  if ClassifyPair(7, 0) <> 'on-x'      then halt(3);
  if ClassifyPair(3, 4) <> 'somewhere' then halt(4);
end.
