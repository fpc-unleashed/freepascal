program strinterp_nested_01;

{$mode unleashed}

var
  name, tag: string;
  s: string;
begin
  name := 'Alice';
  tag := 'admin';
  s := $'<{$'{tag}:{name}'}>';
  if s <> '<admin:Alice>' then halt(1);
end.
