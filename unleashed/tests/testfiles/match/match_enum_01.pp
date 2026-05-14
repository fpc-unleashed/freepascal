program match_enum_01;

{$mode unleashed}

type
  TFruit = (apple, banana, cherry);

function Color(f: TFruit): String;
begin
  match f of
    apple:  Result := 'red';
    banana: Result := 'yellow';
    cherry: Result := 'red';
  end;
end;

begin
  if Color(apple)  <> 'red'    then halt(1);
  if Color(banana) <> 'yellow' then halt(2);
  if Color(cherry) <> 'red'    then halt(3);
end.
