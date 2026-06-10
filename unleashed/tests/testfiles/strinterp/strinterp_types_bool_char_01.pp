program strinterp_types_bool_char_01;

{$mode unleashed}

var
  flag: boolean;
  c: char;
  s: string;
begin
  flag := true;
  s := $'{flag}';
  if s <> 'TRUE' then halt(1);

  flag := false;
  s := $'{flag}';
  if s <> 'FALSE' then halt(2);

  c := 'X';
  s := $'[{c}]';
  if s <> '[X]' then halt(3);
end.
