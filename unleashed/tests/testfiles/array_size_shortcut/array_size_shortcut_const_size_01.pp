program array_size_shortcut_const_size_01;

{$mode unleashed}

const
  BUF = 8;

var
  big: array[BUF] of Byte;
  i, sum: Integer;
begin
  for i := 0 to BUF - 1 do
    big[i] := Byte(i + 1);
  sum := 0;
  for i := 0 to BUF - 1 do
    sum := sum + big[i];
  if sum <> 36 then halt(1);
end.
