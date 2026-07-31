program array_equality_chararray_vs_string_const_01;

{$mode unleashed}

const
  MAGIC = 'FIPACK';

var
  a: array[0..5] of char;
  b: array[6] of char;

begin
  a := MAGIC;
  b := MAGIC;
  if not (a = MAGIC) then halt(1);
  if not (b = MAGIC) then halt(2);
  if a <> MAGIC then halt(3);
  if not (MAGIC = a) then halt(4);
  a[0] := 'X';
  if a = MAGIC then halt(5);
  if not (a <> MAGIC) then halt(6);
end.
