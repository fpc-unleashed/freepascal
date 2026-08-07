program prepostincdec_statement_09;
{$mode unleashed}
var
  a: Integer;
begin
  a := 1;
  // legal in statement position, value discarded
  PostInc(a);
  PreInc(a, 2);
  PostDec(a);
  PreDec(a, 2);
  if a <> 1 then halt(1);
end.
