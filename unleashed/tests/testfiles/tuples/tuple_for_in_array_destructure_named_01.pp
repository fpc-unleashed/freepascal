program tuple_for_in_array_destructure_named_01;

{$mode unleashed}

uses SysUtils;

begin
  var entries: array of (key: String; val: Integer);
  entries := [('a', 1), ('b', 2), ('c', 3)];

  var concat := '';
  var sum := 0;
  for var (k, v) in entries do
  begin
    concat := concat + k;
    sum := sum + v;
  end;
  if concat <> 'abc' then halt(1);
  if sum    <> 6     then halt(2);
end.
