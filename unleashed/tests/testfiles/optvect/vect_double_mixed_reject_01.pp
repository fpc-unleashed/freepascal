{ %OPT="-O4 -OoVECTORIZE -Cfsse64" }
{ Mixed single/double precision must NOT vectorize (a packed op of the wrong lane
  width would miscompile): a double destination with a single source, a single
  destination with double sources, and a cross-precision copy all fall back to
  correct scalar code. Each result is checked against an independent recompute at
  the destination precision -- the real guard against a mixed-type miscompile. }
program vect_double_mixed_reject_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var ad,cd: array of double; asg,bsg: array of single; i: longint; dd: double; sg: single;
begin
  SetLength(ad,n); SetLength(cd,n); SetLength(asg,n); SetLength(bsg,n);
  for i:=0 to n-1 do begin cd[i]:=i*0.25-2; bsg[i]:=i*0.5+1; end;

  { double dest, single source: single b promoted to double, computed in double }
  for i:=0 to n-1 do ad[i]:=bsg[i]+cd[i];
  for i:=0 to n-1 do begin dd:=bsg[i]+cd[i]; if ad[i]<>dd then Halt(1); end;

  { single dest, double sources: double add then narrowed to single }
  for i:=0 to n-1 do asg[i]:=cd[i]*2.0;
  for i:=0 to n-1 do begin sg:=cd[i]*2.0; if asg[i]<>sg then Halt(2); end;

  { single dest, double copy: narrowing convert per element }
  for i:=0 to n-1 do asg[i]:=cd[i];
  for i:=0 to n-1 do begin sg:=cd[i]; if asg[i]<>sg then Halt(3); end;
end;
var k: longint;
begin
  for k:=0 to 17 do work(k);
  work(100);
end.
