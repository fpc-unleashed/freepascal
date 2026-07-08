{ %OPT="-O4 -OoLOOPDISTPAT" }
{ Element-wise copy  a[i]:=b[i]  between two dynamic arrays lowers to Move.
  Two dynamic-array references can only fully alias (offset 0) or be disjoint,
  so Move reproduces the forward element copy in every case, including the
  self-copy  a[i]:=a[i]  and after  a:=b  (shared block). Covers ordinal, float
  and unmanaged-record element types across trip counts 0,1,odd,even,large. }
program distpat_copy_01;
{$mode objfpc}{$H+}
type TR = record x: double; y: longint; z: word; end;

procedure work(n: longint);
var
  a,b: array of longint;
  s,t: array of single;
  ra,rb: array of TR;
  i: longint;
begin
  SetLength(a,n); SetLength(b,n);
  SetLength(s,n); SetLength(t,n);
  SetLength(ra,n); SetLength(rb,n);
  for i:=0 to n-1 do begin
    b[i]:=i*7-3;
    t[i]:=i*0.5-2.0;
    rb[i].x:=i*1.5; rb[i].y:=-i; rb[i].z:=i and $FFFF;
  end;

  { plain copies -> Move }
  for i:=0 to n-1 do a[i]:=b[i];
  for i:=0 to n-1 do s[i]:=t[i];
  for i:=0 to n-1 do ra[i]:=rb[i];
  for i:=0 to n-1 do begin
    if a[i]<>b[i] then Halt(1);
    if s[i]<>t[i] then Halt(2);
    if (ra[i].x<>rb[i].x) or (ra[i].y<>rb[i].y) or (ra[i].z<>rb[i].z) then Halt(3);
  end;

  { self copy a[i]:=a[i] -> Move onto itself, must be a no-op }
  for i:=0 to n-1 do a[i]:=a[i];
  for i:=0 to n-1 do if a[i]<>b[i] then Halt(4);

  { shared block: a := b then copy -> src=dst at offset 0, still correct }
  a:=b;
  for i:=0 to n-1 do a[i]:=b[i];
  for i:=0 to n-1 do if a[i]<>i*7-3 then Halt(5);
end;

var k: longint;
begin
  for k:=0 to 17 do work(k);
  work(100);
  work(1000);
end.
