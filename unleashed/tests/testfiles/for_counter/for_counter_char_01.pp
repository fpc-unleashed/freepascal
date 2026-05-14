program for_counter_char_01;

{$mode unleashed}

var
  ch: Char;

begin
  for ch := 'a' to 'z' do
    ;
  if ch <> 'z' then halt(1);
end.
