{ %OPT=-O4 }
{ Every predictive-commoning decline path must still compute the correct result
  (the pass leaves the loop exactly as written when it cannot prove the rewrite
  sound).  Covered: an in-place stencil that stores into the base array itself
  (would carry the pre-store value -- declined), a loop that both reads and
  writes the same base, a call in the body, a conditional (if) in the body, a
  downto loop, and an address-taken counter.  Each is checked against an
  explicit reference. }
program predcom_negatives_01;
{$mode objfpc}{$H+}

function dval(i: longint): double; begin dval := i*0.5 + 1.25; end;

{ IN-PLACE forward stencil: store target IS the base b -> declined; must keep
  the original sequential (pre-value where already overwritten) semantics }
procedure inplace(var b: array of double; n: longint);
var i: longint;
begin
  for i:=1 to n-2 do b[i]:=b[i-1]+b[i]+b[i+1];
end;

{ read+write same base at an offset -> declined }
procedure rw(var b: array of longint; n: longint);
var i: longint;
begin
  for i:=1 to n-1 do b[i]:=b[i-1]+1;
end;

{ call in the body -> declined }
function twice(x: double): double; begin twice:=x*2; end;
procedure withcall(var a: array of double; n: longint);
var b: array of double; i: longint;
begin
  setlength(b,n);
  for i:=0 to n-1 do b[i]:=dval(i);
  for i:=1 to n-2 do a[i]:=b[i-1]+twice(b[i])+b[i+1];
end;

{ conditional in the body -> declined (the reads are not unconditional) }
procedure withif(var a: array of double; n: longint);
var b: array of double; i: longint;
begin
  setlength(b,n);
  for i:=0 to n-1 do b[i]:=dval(i);
  for i:=1 to n-2 do
    if b[i]>0 then a[i]:=b[i-1]+b[i+1] else a[i]:=0;
end;

{ downto -> declined; values are order-independent here so still correct }
procedure downto_(var a: array of double; n: longint);
var b: array of double; i: longint;
begin
  setlength(b,n);
  for i:=0 to n-1 do b[i]:=dval(i);
  for i:=n-2 downto 1 do a[i]:=b[i-1]+b[i]+b[i+1];
end;

{ address-taken counter -> declined }
procedure addrcnt(var a: array of double; n: longint);
var b: array of double; i: longint; pi: ^longint;
begin
  setlength(b,n);
  for i:=0 to n-1 do b[i]:=dval(i);
  pi:=@i;
  for i:=1 to n-2 do a[i]:=b[i-1]+b[i]+b[i+1];
  if pi^<0 then Halt(9);
end;

var b, a, ref: array of double; bi, ai, ri: array of longint;
    i, n: longint;
begin
  n:=12;
  { in-place: reference computes sequentially in place }
  setlength(b,n); setlength(ref,n);
  for i:=0 to n-1 do begin b[i]:=dval(i); ref[i]:=dval(i); end;
  inplace(b,n);
  for i:=1 to n-2 do ref[i]:=ref[i-1]+ref[i]+ref[i+1];
  for i:=0 to n-1 do if b[i]<>ref[i] then Halt(1);

  { read+write same base }
  setlength(bi,n); setlength(ri,n);
  for i:=0 to n-1 do begin bi[i]:=i; ri[i]:=i; end;
  rw(bi,n);
  for i:=1 to n-1 do ri[i]:=ri[i-1]+1;
  for i:=0 to n-1 do if bi[i]<>ri[i] then Halt(2);

  { call in body }
  setlength(a,n);
  for i:=0 to n-1 do a[i]:=-1;
  withcall(a,n);
  for i:=1 to n-2 do if a[i]<>dval(i-1)+dval(i)*2+dval(i+1) then Halt(3);

  { conditional }
  for i:=0 to n-1 do a[i]:=-1;
  withif(a,n);
  for i:=1 to n-2 do
    if dval(i)>0 then begin if a[i]<>dval(i-1)+dval(i+1) then Halt(4); end
    else if a[i]<>0 then Halt(4);

  { downto }
  for i:=0 to n-1 do a[i]:=-1;
  downto_(a,n);
  for i:=1 to n-2 do if a[i]<>dval(i-1)+dval(i)+dval(i+1) then Halt(5);

  { address-taken counter }
  for i:=0 to n-1 do a[i]:=-1;
  addrcnt(a,n);
  for i:=1 to n-2 do if a[i]<>dval(i-1)+dval(i)+dval(i+1) then Halt(6);

  Halt(0);
end.
