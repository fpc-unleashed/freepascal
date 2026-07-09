program aliasmain;
{$mode objfpc}
uses aliaslib;
var a,b: longint;
begin
  a:=Compute(2,3,4,5);
  b:=ComputeTaken(2,3,4,5);
  { Foo(2,3,4,5)=Bar(2,3,4,5), so Compute = 2*Foo; likewise ComputeTaken=2*Ping }
  if (a and 1)<>0 then begin Writeln('BAD-A'); Halt(1); end;   { must be even }
  if (b and 1)<>0 then begin Writeln('BAD-B'); Halt(2); end;
  if not PtrsDistinct then begin Writeln('BAD-PTR'); Halt(3); end;
  Writeln('OK ',a,' ',b);
end.
