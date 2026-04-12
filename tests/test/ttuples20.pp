{ %FAIL }
{$mode unleashed}
{ test that variable tuple index is a compile error }
program ttuples20;

var
  t: (Integer, Integer);
  i: Integer;
begin
  t := (10, 20);
  i := 0;
  WriteLn(t[i]);  { must fail: tuple index must be constant }
end.
