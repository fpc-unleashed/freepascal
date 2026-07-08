{ %OPT="-O4 -OoLOOPFUSE -vn" }
{ A run of more than two adjacent same-space, same-counter loops must all
  collapse into one fused loop (the greedy fold folds each following loop into
  the survivor), and the result must match the separate-loop computation. Also
  checks a mixed run where a same-counter chain is followed by a different-
  counter loop (bound via c2:=c1). }
program fuse_chain_01;
{$mode objfpc}{$H+}

function chain(n: longint): double;
var a,b,c,d: array of single; i: longint; acc: double;
begin
  SetLength(a,n); SetLength(b,n); SetLength(c,n); SetLength(d,n);
  for i:=0 to n-1 do a[i]:=i+1.0;
  for i:=0 to n-1 do b[i]:=a[i]*2.0;
  for i:=0 to n-1 do c[i]:=b[i]+a[i];
  for i:=0 to n-1 do d[i]:=c[i]-b[i];
  acc:=0;
  for i:=0 to n-1 do acc:=acc+d[i];
  chain:=acc;
end;

function chain_ref(n: longint): double;
var a,b,c,d: array of single; i: longint; acc: double;
begin
  SetLength(a,n); SetLength(b,n); SetLength(c,n); SetLength(d,n);
  acc:=0;
  for i:=0 to n-1 do
    begin
      a[i]:=i+1.0;
      b[i]:=a[i]*2.0;
      c[i]:=b[i]+a[i];
      d[i]:=c[i]-b[i];
      acc:=acc+d[i];
    end;
  chain_ref:=acc;
end;

{ same-counter pair then a different-counter loop }
function mixed(n: longint): double;
var a,b,e: array of single; i,j: longint; acc: double;
begin
  SetLength(a,n); SetLength(b,n); SetLength(e,n);
  for i:=0 to n-1 do a[i]:=i*1.0;
  for i:=0 to n-1 do b[i]:=a[i]+1.0;
  for j:=0 to n-1 do e[j]:=b[j]*b[j];
  acc:=0;
  for i:=0 to n-1 do acc:=acc+e[i];
  mixed:=acc;
end;

function mixed_ref(n: longint): double;
var a,b,e: array of single; i: longint; acc: double;
begin
  SetLength(a,n); SetLength(b,n); SetLength(e,n);
  acc:=0;
  for i:=0 to n-1 do
    begin
      a[i]:=i*1.0;
      b[i]:=a[i]+1.0;
      e[i]:=b[i]*b[i];
      acc:=acc+e[i];
    end;
  mixed_ref:=acc;
end;

var n: longint;
begin
  for n:=0 to 33 do
    begin
      if Abs(chain(n)-chain_ref(n))>1e-2 then Halt(1);
      if Abs(mixed(n)-mixed_ref(n))>1e-2 then Halt(2);
    end;
end.
