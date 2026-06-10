program strinterp_basic_var_01;

{$mode unleashed}

var
  name: string;
  s: string;
begin
  name := 'Alice';
  s := $'Hello {name}!';
  if s <> 'Hello Alice!' then halt(1);

  s := $'{name}';
  if s <> 'Alice' then halt(2);

  s := $'{name}{name}';
  if s <> 'AliceAlice' then halt(3);
end.
