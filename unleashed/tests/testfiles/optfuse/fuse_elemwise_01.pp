{ %OPT="-O4 -OoLOOPFUSE -vn" }
{ Loop fusion (-OoLOOPFUSE) correctness: two adjacent counted element-wise
  loops over the same iteration space are merged, and the fused code must
  compute exactly what the two separate loops did. Covers the producer/consumer
  shape neural-api runs (loop 2 reads a[i] loop 1 just wrote), distinct arrays,
  an in-place update, same and different counters, and boundary lengths 0/1/2. }
program fuse_elemwise_01;
{$mode objfpc}{$H+}

{ producer/consumer: c[i]:=a[i]+b[i] then a[i]:=c[i]*2 (same counter i);
  returns sum of a to a checksum. Fuses into one loop. }
function pc(n: longint): double;
var
  a,b,c: array of single;
  i: longint;
  acc: double;
begin
  SetLength(a,n); SetLength(b,n); SetLength(c,n);
  for i:=0 to n-1 do begin a[i]:=i*1.5; b[i]:=i-3.0; end;
  for i:=0 to n-1 do c[i]:=a[i]+b[i];
  for i:=0 to n-1 do a[i]:=c[i]*2.0;
  acc:=0;
  for i:=0 to n-1 do acc:=acc+a[i];
  pc:=acc;
end;

{ same as pc but computed with no fusable adjacency (a barrier statement between
  every pair) so the compiler cannot fuse -- the reference result. }
function pc_ref(n: longint): double;
var
  a,b,c: array of single;
  i: longint;
  acc: double;
  barrier: longint;
begin
  SetLength(a,n); SetLength(b,n); SetLength(c,n);
  barrier:=0;
  for i:=0 to n-1 do begin a[i]:=i*1.5; b[i]:=i-3.0; end;
  inc(barrier);
  for i:=0 to n-1 do c[i]:=a[i]+b[i];
  inc(barrier);
  for i:=0 to n-1 do a[i]:=c[i]*2.0;
  acc:=0;
  for i:=0 to n-1 do acc:=acc+a[i];
  pc_ref:=acc+barrier-barrier;
end;

{ different counters: gradient accumulate then weight update, i and j }
function accupd(n: longint): double;
var
  g,d,w: array of single;
  i,j: longint;
  acc: double;
begin
  SetLength(g,n); SetLength(d,n); SetLength(w,n);
  for i:=0 to n-1 do begin g[i]:=1.0; d[i]:=i*0.5; w[i]:=100.0; end;
  for i:=0 to n-1 do g[i]:=g[i]+d[i];
  for j:=0 to n-1 do w[j]:=w[j]-0.25*g[j];
  acc:=0;
  for i:=0 to n-1 do acc:=acc+w[i];
  accupd:=acc;
end;

function accupd_ref(n: longint): double;
var
  g,d,w: array of single;
  i,j: longint;
  acc: double;
begin
  SetLength(g,n); SetLength(d,n); SetLength(w,n);
  for i:=0 to n-1 do begin g[i]:=1.0; d[i]:=i*0.5; w[i]:=100.0; end;
  acc:=0;
  for i:=0 to n-1 do
    begin
      g[i]:=g[i]+d[i];
      w[i]:=w[i]-0.25*g[i];
      acc:=acc+w[i];
    end;
  { j is unused here but referenced to silence hints }
  j:=0;
  accupd_ref:=acc+j;
end;

var
  n: longint;
begin
  for n:=0 to 40 do
    begin
      if Abs(pc(n)-pc_ref(n))>1e-3 then Halt(1);
      if Abs(accupd(n)-accupd_ref(n))>1e-3 then Halt(2);
    end;
  { explicit boundary spot checks }
  if pc(0)<>0.0 then Halt(3);
  if pc(1)<>pc_ref(1) then Halt(4);
end.
