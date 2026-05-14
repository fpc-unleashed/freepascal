program tuple_returned_into_existing_vars_01;

{$mode unleashed}

function NameAndAge: (String, Integer);
begin
  Result := ('Alice', 30);
end;

var
  who: String;
  age: Integer;

begin
  (who, age) := NameAndAge;
  if who <> 'Alice' then halt(1);
  if age <> 30      then halt(2);
end.
