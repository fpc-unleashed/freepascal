program strinterp_basic_plain_01;

{$mode unleashed}

var
  s: string;
begin
  s := $'hello world';
  if s <> 'hello world' then halt(1);

  s := $'';
  if s <> '' then halt(2);

  s := $'a';
  if s <> 'a' then halt(3);
end.
