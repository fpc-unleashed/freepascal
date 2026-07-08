{ %OPT="-O4 -OoLOOPFUSE -vn" }
{ Shapes the fusion pass must DECLINE, each emitting a cg_n_loop_not_fused
  (06074) note naming the reason. Fusion is a measure-only transform, so a
  declined pair must still compute exactly what the two separate loops did.
  Decline reasons exercised: different upper bound, cross-iteration a[i+1] read,
  downto direction, a non-whitelisted intrinsic (Trunc) in the body, a scalar carried
  across the boundary, a non-loop statement between the loops (not adjacent),
  a nested loop in the body, and a whole-scalar/field write. }
program fuse_negatives_01;
{$mode objfpc}{$H+}

procedure diffbound(n: longint);
var a,b: array of longint; i: longint;
begin
  SetLength(a,n+1); SetLength(b,n+1);
  for i:=0 to n   do a[i]:=i;      { upper bound n }
  for i:=0 to n-1 do b[i]:=i*2;    { upper bound n-1: different space }
  for i:=0 to n   do if a[i]<>i then Halt(1);
  for i:=0 to n-1 do if b[i]<>i*2 then Halt(2);
end;

procedure crossiter(n: longint);
var a,b: array of longint; i: longint;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do a[i]:=i;
  if n>=2 then
    begin
      for i:=1 to n-1 do b[i]:=a[i-1];    { a[i-1]: cross-iteration }
      for i:=1 to n-1 do if b[i]<>i-1 then Halt(3);
    end;
end;

procedure downdir(n: longint);
var a,b: array of longint; i: longint;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=n-1 downto 0 do a[i]:=i;
  for i:=n-1 downto 0 do b[i]:=a[i]+1;
  for i:=0 to n-1 do if (a[i]<>i) or (b[i]<>i+1) then Halt(4);
end;

procedure intrins(n: longint);
var a: array of single; b: array of longint; i: longint;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do a[i]:=i+0.5;
  for i:=0 to n-1 do b[i]:=Trunc(a[i]);     { Trunc: non-whitelisted intrinsic }
  for i:=0 to n-1 do if b[i]<>Trunc(i+0.5) then Halt(5);
end;

procedure scalarcarry(n: longint);
var a,b: array of longint; i,s: longint;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do a[i]:=i;
  s:=0;
  for i:=0 to n-1 do s:=s+a[i];             { writes scalar s }
  for i:=0 to n-1 do b[i]:=s;
  for i:=0 to n-1 do if b[i]<>s then Halt(6);
end;

procedure notadjacent(n: longint);
var a,b: array of longint; i,mark: longint;
begin
  SetLength(a,n); SetLength(b,n);
  mark:=0;
  for i:=0 to n-1 do a[i]:=i;
  mark:=99;                                  { real statement between loops }
  for i:=0 to n-1 do b[i]:=a[i]+mark;
  for i:=0 to n-1 do if b[i]<>i+99 then Halt(7);
end;

procedure nestedloop(n: longint);
var a,b: array of longint; i,k,acc: longint;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do a[i]:=i;
  for i:=0 to n-1 do
    begin
      acc:=0;
      for k:=0 to 2 do acc:=acc+a[i];       { nested loop -> declined }
      b[i]:=acc;
    end;
  for i:=0 to n-1 do if b[i]<>3*i then Halt(8);
end;

var n: longint;
begin
  for n:=0 to 6 do
    begin
      diffbound(n); crossiter(n); downdir(n);
      intrins(n); scalarcarry(n); notadjacent(n); nestedloop(n);
    end;
end.
