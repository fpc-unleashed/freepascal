program xumain;
{$mode objfpc}
uses xulibA, xulibB;
begin
  if CalcA(2,3,4,5) <> CalcB(2,3,4,5) then begin Writeln('BAD1'); Halt(1); end;
  if CalcBdiff(2,3,4,5) = CalcB(2,3,4,5) then begin Writeln('BAD2'); Halt(2); end;
  Writeln('OK ', CalcB(2,3,4,5), ' ', CalcBdiff(2,3,4,5));
end.
