{ %OPT="-O4 -vn" }
{ Plain -O4 (no explicit -OoLOOPFUSE) must enable loop fusion, since
  cs_opt_loopfuse is in genericlevel4optimizerswitches. The pair below is a
  clean same-space element-wise producer/consumer that the pass fuses; the
  result must equal the two-pass computation. }
program fuse_o4_default_01;
{$mode objfpc}{$H+}

function run(n: longint): double;
var a,b,c: array of single; i: longint; acc: double;
begin
  SetLength(a,n); SetLength(b,n); SetLength(c,n);
  for i:=0 to n-1 do begin a[i]:=i+1.0; b[i]:=2.0*i; end;
  for i:=0 to n-1 do c[i]:=a[i]*b[i];
  for i:=0 to n-1 do a[i]:=c[i]+b[i];
  acc:=0;
  for i:=0 to n-1 do acc:=acc+a[i];
  run:=acc;
end;

var
  n: longint;
  expect: double;
  i: longint;
begin
  for n:=0 to 20 do
    begin
      expect:=0;
      for i:=0 to n-1 do
        expect:=expect + ((i+1.0)*(2.0*i) + 2.0*i);
      if Abs(run(n)-expect)>1e-3 then Halt(1);
    end;
end.
