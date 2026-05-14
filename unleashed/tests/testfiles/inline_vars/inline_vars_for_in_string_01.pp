program inline_vars_for_in_string_01;

{$mode unleashed}

var
  count: Integer;

begin
  count := 0;
  for var ch in 'hello' do
    Inc(count);
  if count <> 5 then halt(1);
end.
