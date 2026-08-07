program prepostincdec_enum_char_04;
{$mode unleashed}
type
  tcolor = (cred, cgreen, cblue, cyellow);
var
  col: tcolor;
  c: Char;
begin
  col := cred;
  if PostInc(col) <> cred then halt(1);
  if col <> cgreen then halt(2);
  if PreInc(col, 2) <> cyellow then halt(3);
  if PostDec(col) <> cyellow then halt(4);
  if PreDec(col, 2) <> cred then halt(5);
  c := 'a';
  if PostInc(c) <> 'a' then halt(6);
  if PreInc(c) <> 'c' then halt(7);
  if c <> 'c' then halt(8);
end.
