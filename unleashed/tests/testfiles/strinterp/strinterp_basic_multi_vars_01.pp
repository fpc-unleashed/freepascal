program strinterp_basic_multi_vars_01;

{$mode unleashed}

var
  a, b: string;
  s: string;
begin
  a := 'foo';
  b := 'bar';
  s := $'{a} and {b}';
  if s <> 'foo and bar' then halt(1);

  s := $'[{a}][{b}]';
  if s <> '[foo][bar]' then halt(2);
end.
