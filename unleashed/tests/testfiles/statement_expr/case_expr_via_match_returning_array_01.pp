program case_expr_via_match_returning_array_01;

{$mode unleashed}

function PalleteFor(name: String): array of Integer;
begin
  Result := match name of
    'red':   [255, 0, 0];
    'green': [0, 255, 0];
    'blue':  [0, 0, 255];
    _:       [128, 128, 128];
  end;
end;

begin
  var rgb := PalleteFor('green');
  if Length(rgb) <> 3 then halt(1);
  if rgb[1] <> 255    then halt(2);

  rgb := PalleteFor('mystery');
  if rgb[0] <> 128    then halt(3);
end.
