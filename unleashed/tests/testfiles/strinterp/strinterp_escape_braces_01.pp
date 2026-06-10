program strinterp_escape_braces_01;

{$mode unleashed}

var
  s: string;
  n: integer;
begin
  n := 7;
  s := $'literal {{ and }}';
  if s <> 'literal { and }' then halt(1);

  s := $'{{{n}}}';
  if s <> '{7}' then halt(2);
end.
